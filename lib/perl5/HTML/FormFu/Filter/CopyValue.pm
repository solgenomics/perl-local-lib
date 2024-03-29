use strict;

package HTML::FormFu::Filter::CopyValue;
$HTML::FormFu::Filter::CopyValue::VERSION = '2.07';
# ABSTRACT: copy the value from another field

use Moose;
use MooseX::Attribute::Chained;
extends 'HTML::FormFu::Filter';

with 'HTML::FormFu::Role::NestedHashUtils';

has field => ( is => 'rw', traits => ['Chained'] );

sub filter {
    my ( $self, $value ) = @_;

    return $value
        if ( defined $value && length $value );

    my $field_name = $self->field
        or die "Parameter 'field' is not defined.";

    my $parent = $self->parent
        or die "Can't determine my parent.";

    my $field_value
        = $self->get_nested_hash_value( $parent->form->input, $field_name, );

    return $field_value;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

HTML::FormFu::Filter::CopyValue - copy the value from another field

=head1 VERSION

version 2.07

=head1 SYNOPSIS

   elements:
      - type: Text
        name: username
      - type: Text
        name: nickname
        filters:
           - type: CopyValue
             field: username

=head1 DESCRIPTION

Filter copying the value of another field if the original value of this field
is empty.

=head1 CAVEATS

If the original field contains an invalid value (a value that will be
constrained through a constraint) that invalid value will be copied to this
field (the field with the CopyValue filter).  So, the user has to change two
fields, or you can remove the invalid value in a custom constraint.

=head1 AUTHOR

Mario Minati, C<mario.minati@googlemail.com>

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
