use strict;

package HTML::FormFu::Element::Hr;
$HTML::FormFu::Element::Hr::VERSION = '2.07';
# ABSTRACT: horizontal-rule element

use Moose;

extends 'HTML::FormFu::Element';

with 'HTML::FormFu::Role::Element::NonBlock';

after BUILD => sub {
    my $self = shift;

    $self->tag('hr');

    return;
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

HTML::FormFu::Element::Hr - horizontal-rule element

=head1 VERSION

version 2.07

=head1 DESCRIPTION

Horizontal-rule element.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from
L<HTML::FormFu::Role::Element::NonBlock>,
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

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
