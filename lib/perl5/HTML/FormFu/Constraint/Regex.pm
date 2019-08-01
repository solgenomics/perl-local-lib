use strict;

package HTML::FormFu::Constraint::Regex;
$HTML::FormFu::Constraint::Regex::VERSION = '2.07';
# ABSTRACT: Regex Constraint

use Moose;
use MooseX::Attribute::Chained;
extends 'HTML::FormFu::Constraint';

use Regexp::Common;

has common   => ( is => 'rw', traits => ['Chained'] );
has regex    => ( is => 'rw', traits => ['Chained'] );
has anchored => ( is => 'rw', traits => ['Chained'] );

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    my $regex;

    if ( defined $self->regex ) {
        $regex = $self->regex;
    }
    elsif ( defined $self->common ) {
        my @common
            = ref $self->common
            ? @{ $self->common }
            : $self->common;

        $regex = shift @common;
        $regex = $RE{$regex};

        for (@common) {
            $regex = $regex->{ ref $_ ? join( $;, %$_ ) : $_ };
        }
    }
    else {
        $regex = qr/.*/;
    }

    if ( $self->anchored ) {
        $regex = qr{^$regex\z};
    }

    my $ok = $value =~ $regex;

    return $self->not ? !$ok : $ok;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

HTML::FormFu::Constraint::Regex - Regex Constraint

=head1 VERSION

version 2.07

=head1 DESCRIPTION

Regular expression-based constraint.

=head1 METHODS

=head2 regex

Arguments: $regex. In a config file, enclose the regex in a string, like this: C<regex: '^[-_+=!\w\d]*\z'>.

Arguments: $string

=head2 common

Arguments: \@parts

Used to build a L<Regexp::Common> regex.

The following definition is equivalent to
C<< $RE{URI}{HTTP}{-scheme => 'https?'} >>

    type: Regex
    common:
      - URI
      - HTTP
      - { '-scheme': 'https?' }

=-head2 anchored

Arguments: bool

If true, uses C<^> and C<\z> to anchor the L</regex> or L</common>
to the start and end of the submitted value.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Constraint::Regex>, by
Sebastian Riedel, C<sri@oook.de>.

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
