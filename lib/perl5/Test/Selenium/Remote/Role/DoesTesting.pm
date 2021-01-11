package Test::Selenium::Remote::Role::DoesTesting;
$Test::Selenium::Remote::Role::DoesTesting::VERSION = '1.39';
# ABSTRACT: Role to cope with everything that is related to testing (could
# be reused in both testing classes)

use Moo::Role;
use Test::Builder;
use Try::Tiny;
use Scalar::Util 'blessed';
use List::Util qw/any/;
use namespace::clean;

requires qw(func_list has_args);

has _builder => (
    is      => 'lazy',
    builder => sub { return Test::Builder->new() },
    handles => [qw/is_eq isnt_eq like unlike ok croak/],
);

# get back the key value from an already coerced finder (default finder)

sub _get_finder_key {
    my $self         = shift;
    my $finder_value = shift;
    foreach my $k ( keys %{ $self->FINDERS } ) {
        return $k if ( $self->FINDERS->{$k} eq $finder_value );
    }
    return;
}

# main method for non ok tests

sub _check_method {
    my $self           = shift;
    my $method         = shift;
    my $method_to_test = shift;
    $method = "get_$method";
    my @args = @_;
    my $rv;
    try {
        my $num_of_args = $self->has_args($method);
        my @r_args = splice( @args, 0, $num_of_args );
        $rv = $self->$method(@r_args);
    }
    catch {
        $self->croak($_);
    };

    return $self->$method_to_test( $rv, @args );
}

# main method for _ok tests
# a bit hacked so that find_no_element_ok can also be processed

sub _check_ok {
    my $self        = shift;
    my $method      = shift;
    my $real_method = '';
    my @args        = @_;
    my ( $rv, $num_of_args, @r_args );
    try {
        $num_of_args = $self->has_args($method);
        @r_args = splice( @args, 0, $num_of_args );
        if ( $method =~ m/^find(_no|_child)?_element/ ) {

            # case find_element_ok was called with no arguments
            if ( scalar(@r_args) - $num_of_args == 1 ) {
                push @r_args, $self->_get_finder_key( $self->default_finder );
            }
            else {
                if ( scalar(@r_args) == $num_of_args ) {

                    # case find_element was called with no finder but
                    # a test description
                    my $finder  = $r_args[ $num_of_args - 1 ];
                    my @FINDERS = keys( %{ $self->FINDERS } );
                    unless ( any { $finder eq $_ } @FINDERS ) {
                        $r_args[ $num_of_args - 1 ] =
                          $self->_get_finder_key( $self->default_finder );
                        push @args, $finder;
                    }
                }
            }
        }

        # quick hack to fit 'find_no_element' into check_ok logic
        if ( $method eq 'find_no_element' ) {
            $real_method = $method;

            # If we use `find_element` and find nothing, the error
            # handler is incorrectly invoked. Doing a `find_elements`
            # and checking that it returns an empty array does not
            # invoke the error_handler. See
            # https://github.com/gempesaw/Selenium-Remote-Driver/issues/253
            $method = 'find_elements';
            my $elements = $self->$method(@r_args);
            if ( scalar(@$elements) ) {
                $rv = $elements->[0];
            }
            else {
                $rv = 1;
            }
        }
        else {
            $rv = $self->$method(@r_args);
        }
    }
    catch {
        if ($real_method) {
            $method = $real_method;
            $rv     = 1;
        }
        else {
            $self->croak($_);
        }
    };

    my $default_test_name = $method;
    $default_test_name .= "'" . join( "' ", @r_args ) . "'"
      if $num_of_args > 0;

    my $test_name = pop @args // $default_test_name;

    # case when find_no_element found an element, we should croak
    if ( $real_method eq 'find_no_element' ) {
        if ( blessed($rv) && $rv->isa('Selenium::Remote::WebElement') ) {
            $self->croak($test_name);
        }
    }
    return $self->ok( $rv, $test_name );
}

# build the subs with the correct arg set

sub _build_sub {
    my $self      = shift;
    my $meth_name = shift;
    my @func_args;
    my $comparators = {
        is     => 'is_eq',
        isnt   => 'isnt_eq',
        like   => 'like',
        unlike => 'unlike',
    };
    my @meth_elements = split( '_', $meth_name );
    my $meth          = '_check_ok';
    my $meth_comp     = pop @meth_elements;
    if ( $meth_comp eq 'ok' ) {
        push @func_args, join( '_', @meth_elements );
    }
    else {
        if ( defined( $comparators->{$meth_comp} ) ) {
            $meth = '_check_method';
            push @func_args, join( '_', @meth_elements ),
              $comparators->{$meth_comp};
        }
        else {
            return sub {
                my $self = shift;
                $self->croak("Sub $meth_name could not be defined");
              }
        }
    }

    return sub {
        my $self = shift;
        local $Test::Builder::Level = $Test::Builder::Level + 2;
        $self->$meth( @func_args, @_ );
    };

}

1;

=head1 NAME

Selenium::Remote::Role::DoesTesting - Role implementing the common logic used for testing

=cut
