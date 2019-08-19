use strict;

package HTML::FormFu::Deflator::Callback;
$HTML::FormFu::Deflator::Callback::VERSION = '2.07';
# ABSTRACT: Callback deflator

use Moose;
use MooseX::Attribute::Chained;
extends 'HTML::FormFu::Deflator';

has callback => ( is => 'rw', traits => ['Chained'] );

sub deflator {
    my ( $self, $value ) = @_;

    my $callback = $self->callback || sub {shift};

    ## no critic (ProhibitNoStrict);
    no strict 'refs';

    return $callback->($value);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

HTML::FormFu::Deflator::Callback - Callback deflator

=head1 VERSION

version 2.07

=head1 SYNOPSIS

    $field->deflator('Callback')->callback( \&my_callback );

    ---
    elements:
      - type: Text
        name: foo
        deflators:
          - type: Callback
            callback: "main::my_deflator"

=head1 DESCRIPTION

Callback deflator.

=head1 METHODS

=head2 callback

Arguments: \&code-reference

Arguments: "subroutine-name"

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Deflator>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=head1 AUTHOR

Carl Franks <cpan@fireartist.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Carl Franks.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut