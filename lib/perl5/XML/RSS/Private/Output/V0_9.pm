package XML::RSS::Private::Output::V0_9;
$XML::RSS::Private::Output::V0_9::VERSION = '1.62';
use strict;
use warnings;

use vars (qw(@ISA));

use XML::RSS::Private::Output::Base ();

@ISA = (qw(XML::RSS::Private::Output::Base));

sub _get_rdf_decl {
    return qq{<rdf:RDF\nxmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"\n}
      . qq{xmlns="http://my.netscape.com/rdf/simple/0.9/">\n\n};
}

# 'description' for item does not exist in RSS 0.9
sub _out_item_desc {
    return;
}

# RSS 0.9 does not support the language tag so we nullify this tag.
sub _out_language {
    return;
}

sub _output_rss_middle {
    my $self = shift;

    $self->_end_channel();
    $self->_output_main_elements;
}

sub _get_end_tag {
    return "rdf:RDF";
}

1;

__END__

=pod

=encoding UTF-8

=head1 VERSION

version 1.62

=for :stopwords cpan testmatrix url bugtracker rt cpants kwalitee diff irc mailto metadata placeholders metacpan

=head1 SUPPORT

=head2 Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

=over 4

=item *

MetaCPAN

A modern, open-source CPAN search engine, useful to view POD in HTML format.

L<https://metacpan.org/release/XML-RSS>

=item *

RT: CPAN's Bug Tracker

The RT ( Request Tracker ) website is the default bug/issue tracking system for CPAN.

L<https://rt.cpan.org/Public/Dist/Display.html?Name=XML-RSS>

=item *

CPANTS

The CPANTS is a website that analyzes the Kwalitee ( code metrics ) of a distribution.

L<http://cpants.cpanauthors.org/dist/XML-RSS>

=item *

CPAN Testers

The CPAN Testers is a network of smoke testers who run automated tests on uploaded CPAN distributions.

L<http://www.cpantesters.org/distro/X/XML-RSS>

=item *

CPAN Testers Matrix

The CPAN Testers Matrix is a website that provides a visual overview of the test results for a distribution on various Perls/platforms.

L<http://matrix.cpantesters.org/?dist=XML-RSS>

=item *

CPAN Testers Dependencies

The CPAN Testers Dependencies is a website that shows a chart of the test results of all dependencies for a distribution.

L<http://deps.cpantesters.org/?module=XML::RSS>

=back

=head2 Bugs / Feature Requests

Please report any bugs or feature requests by email to C<bug-xml-rss at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/Public/Bug/Report.html?Queue=XML-RSS>. You will be automatically notified of any
progress on the request by the system.

=head2 Source Code

The code is open to the world, and available for you to hack on. Please feel free to browse it and play
with it, or whatever. If you want to contribute patches, please send me a diff or prod me to pull
from your repository :)

L<https://github.com/shlomif/perl-XML-RSS>

  git clone git://github.com/shlomif/perl-XML-RSS.git

=head1 AUTHOR

Shlomi Fish <shlomif@cpan.org>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
L<https://github.com/shlomif/perl-XML-RSS/issues>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2001 by Various.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
