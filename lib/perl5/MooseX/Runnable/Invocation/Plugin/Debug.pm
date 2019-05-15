package MooseX::Runnable::Invocation::Plugin::Debug;
BEGIN {
  $MooseX::Runnable::Invocation::Plugin::Debug::AUTHORITY = 'cpan:JROCKWAY';
}
# ABSTRACT: print debugging information
$MooseX::Runnable::Invocation::Plugin::Debug::VERSION = '0.09';
use Moose::Role;
use namespace::autoclean;

with 'MooseX::Runnable::Invocation::Plugin::Role::CmdlineArgs';

# this is an example to cargo-cult, rather than a useful feature :)
has 'debug_prefix' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => sub { "" },
);

sub _build_initargs_from_cmdline {
    my ($class, @args) = @_;
    confess 'Bad args passed to Debug plugin'
      unless @args % 2 == 0;

    my %args = @args;

    if(my $p = $args{'--prefix'}){
        return { debug_prefix => $p };
    }
    return;
}

sub _debug_message {
    my ($self, @msg) = @_;
    print {*STDERR} $self->debug_prefix, "[$$] ", @msg, "\n";
}

for my $method (qw{
    load_class apply_scheme validate_class
    create_instance start_application
  }){
    requires $method;

    before $method => sub {
        my ($self, @args) = @_;
        my $args = join ', ', @args;
        $self->_debug_message("Calling $method($args)");
    };

    after $method => sub {
        my $self = shift;
        $self->_debug_message("Returning from $method");
    };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

MooseX::Runnable::Invocation::Plugin::Debug - print debugging information

=head1 VERSION

version 0.09

=head1 DESCRIPTION

This is an example plugin, showing how you could write your own.  It
prints a message for each stage of the "run" process.  It is also used
by other plugins to determine whether or not to print debugging
messages.

=head1 SEE ALSO

L<MooseX::Runnable>

=head1 AUTHOR

Jonathan Rockway <jrockway@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jonathan Rockway.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
