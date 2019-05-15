#------------------------------------------------------------------
#
# BioPerl module for Bio::SearchIO::IteratedSearchResultEventBuilder
#
# Please direct questions and support issues to <bioperl-l@bioperl.org>
#
# Cared for by Steve Chervitz <sac@bioperl.org> and Jason Stajich <jason@bioperl.org>
#
# Copyright Steve Chervitz
#
# You may distribute this module under the same terms as perl itself
#------------------------------------------------------------------

# POD documentation - main docs before the code

=head1 NAME

Bio::SearchIO::IteratedSearchResultEventBuilder - Event Handler for
SearchIO events.

=head1 SYNOPSIS

# Do not use this object directly, this object is part of the SearchIO
# event based parsing system.

=head1 DESCRIPTION

This object handles Search Events generated by the SearchIO classes
and build appropriate Bio::Search::* objects from them.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Support

Please direct usage questions or support issues to the mailing list:

I<bioperl-l@bioperl.org>

rather than to the module maintainer directly. Many experienced and
reponsive experts will be able look at the problem and quickly
address it. Please include a thorough description of the problem
with code and data examples if at all possible.

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via the
web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Steve Chervitz

Email sac-at-bioperl.org

=head1 CONTRIBUTORS

Parts of code based on SearchResultEventBuilder by Jason Stajich
jason@bioperl.org

Sendu Bala, bix@sendu.me.uk

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::SearchIO::IteratedSearchResultEventBuilder;
$Bio::SearchIO::IteratedSearchResultEventBuilder::VERSION = '1.7.5';
use strict;

use Bio::Factory::ObjectFactory;

use base qw(Bio::SearchIO::SearchResultEventBuilder);

=head2 new

 Title   : new
 Usage   : my $obj = Bio::SearchIO::IteratedSearchResultEventBuilder->new();
 Function: Builds a new Bio::SearchIO::IteratedSearchResultEventBuilder object
 Returns : Bio::SearchIO::IteratedSearchResultEventBuilder
 Args    : -hsp_factory    => Bio::Factory::ObjectFactoryI
           -hit_factory    => Bio::Factory::ObjectFactoryI
           -result_factory => Bio::Factory::ObjectFactoryI
           -iteration_factory => Bio::Factory::ObjectFactoryI
           -inclusion_threshold => e-value threshold for inclusion in the
                                   PSI-BLAST score matrix model (blastpgp)
           -signif      => float or scientific notation number to be used
                           as a P- or Expect value cutoff
           -score       => integer or scientific notation number to be used
                           as a blast score value cutoff
           -bits        => integer or scientific notation number to be used
                           as a bit score value cutoff
           -hit_filter  => reference to a function to be used for
                           filtering hits based on arbitrary criteria.

See L<Bio::SearchIO::SearchResultEventBuilder> for more information

=cut

sub new {
    my ($class,@args) = @_;
    my $self = $class->SUPER::new(@args);
    my ($resultF, $iterationF, $hitF,  $hspF) =
        $self->_rearrange([qw(RESULT_FACTORY
                              ITERATION_FACTORY
                              HIT_FACTORY
                              HSP_FACTORY)],@args);
    $self->_init_parse_params(@args);

    # Note that we need to override the setting of result and factories here
    # so that we can set different default factories than are set by the super class.
    $self->register_factory('result', $resultF ||
                            Bio::Factory::ObjectFactory->new(
                                -type      => 'Bio::Search::Result::BlastResult',
                                -interface => 'Bio::Search::Result::ResultI'));

    $self->register_factory('hit', $hitF ||
                            Bio::Factory::ObjectFactory->new(
                                -type      => 'Bio::Search::Hit::BlastHit',
                                -interface => 'Bio::Search::Hit::HitI'));

    $self->register_factory('hsp', $hspF ||
                            Bio::Factory::ObjectFactory->new(
                                -type      => 'Bio::Search::HSP::GenericHSP',
                                -interface => 'Bio::Search::HSP::HSPI'));

    # TODO: Change this to BlastIteration (maybe)
    $self->register_factory('iteration', $iterationF ||
                            Bio::Factory::ObjectFactory->new(
                                -type      => 'Bio::Search::Iteration::GenericIteration',
                                -interface => 'Bio::Search::Iteration::IterationI'));

    return $self;
}

=head2 will_handle

 Title   : will_handle
 Usage   : if( $handler->will_handle($event_type) ) { ... }
 Function: Tests if this event builder knows how to process a specific event
 Returns : boolean
 Args    : event type name

=cut

sub will_handle{
   my ($self,$type) = @_;
   # these are the events we recognize
   return (   $type eq 'hsp' || $type eq 'hit' || $type eq 'result'
           || $type eq 'iteration' || $type eq 'newhits' || $type eq 'oldhits' );
}

=head2 SAX methods

=cut

=head2 start_result

 Title   : start_result
 Usage   : $handler->start_result($resulttype)
 Function: Begins a result event cycle
 Returns : none
 Args    : Type of Report

=cut

sub start_result {
   my $self = shift;
   #print STDERR "ISREB: start_result()\n";
   $self->SUPER::start_result(@_);
   $self->{'_iterations'} = [];
   $self->{'_iteration_count'} = 0;
   $self->{'_old_hit_names'} = undef;
   $self->{'_hit_names_below'} = undef;
   return;
}

=head2 start_iteration

 Title   : start_iteration
 Usage   : $handler->start_iteration()
 Function: Starts an Iteration event cycle
 Returns : none
 Args    : type of event and associated hashref

=cut

sub start_iteration {
    my ($self,$type) = @_;

    #print STDERR "ISREB: start_iteration()\n";
    $self->{'_iteration_count'}++;

    # Reset arrays for the various classes of hits.
#    $self->{'_newhits_unclassified'}     = [];
    $self->{'_newhits_below'}        = [];
    $self->{'_newhits_not_below'}    = [];
    $self->{'_oldhits_below'}        = [];
    $self->{'_oldhits_newly_below'}  = [];
    $self->{'_oldhits_not_below'}    = [];
    $self->{'_hitcount'} = 0;
    return;
}


=head2 end_iteration

 Title   : end_iteration
 Usage   : $handler->end_iteration()
 Function: Ends an Iteration event cycle
 Returns : Bio::Search::Iteration object
 Args    : type of event and associated hashref

=cut

sub end_iteration {
    my ($self,$type,$data) = @_;

    # print STDERR "ISREB: end_iteration()\n";

    my %args = map { my $v = $data->{$_}; s/ITERATION//; ($_ => $v); }
    grep { /^ITERATION/ } keys %{$data};

    $args{'-number'} = $self->{'_iteration_count'};
    $args{'-oldhits_below'} = $self->{'_oldhits_below'};
    $args{'-oldhits_newly_below'} = $self->{'_oldhits_newly_below'};
    $args{'-oldhits_not_below'} = $self->{'_oldhits_not_below'};
    $args{'-newhits_below'} = $self->{'_newhits_below'};
    $args{'-newhits_not_below'} = $self->{'_newhits_not_below'};
    $args{'-hit_factory'} = $self->factory('hit');

    my $it = $self->factory('iteration')->create_object(%args);
    push @{$self->{'_iterations'}}, $it;
    return $it;
}

# Title   : _add_hit (private function for internal use only)
# Purpose : Applies hit filtering and calls _store_hit if it passes filtering.
# Argument: Bio::Search::Hit::HitI object

sub _add_hit {
    my ($self, $hit) = @_;

    my $hit_name   = uc($hit->{-name});
    my $hit_signif = $hit->{-significance};
    my $ithresh    = $self->{'_inclusion_threshold'};

    # Test significance using custom function (if supplied)
    my $add_hit = 1;

    my $hit_filter = $self->{'_hit_filter'};

    if($hit_filter) {
        # since &hit_filter is out of our control and would expect a HitI object,
        # we're forced to make one for it
        $hit = $self->factory('hit')->create_object(%{$hit});
        $add_hit = 0 unless &$hit_filter($hit);
    }
    else {
        if($self->{'_confirm_significance'}) {
            $add_hit = 0 unless $hit_signif <= $self->{'_max_significance'};
        }
        if($self->{'_confirm_score'}) {
            my $hit_score = $hit->{-score} || $hit->{-hsps}->[0]->{-score};
            $add_hit = 0 unless $hit_score >= $self->{'_min_score'};
        }
        if($self->{'_confirm_bits'}) {
            my $hit_bits = $hit->{-bits} || $hit->{-hsps}->[0]->{-bits};
            $add_hit = 0 unless $hit_bits >= $self->{'_min_bits'};
        }
    }

    $add_hit && $self->_store_hit($hit, $hit_name, $hit_signif);
    # Building hit lookup hashes for determining if the hit is old/new and
    # above/below threshold.
    $self->{'_old_hit_names'}->{$hit_name}++;
    $self->{'_hit_names_below'}->{$hit_name}++ if $hit_signif <= $ithresh;
}

# Title   : _store_hit (private function for internal use only)
# Purpose : Collects hit objects into defined sets that are useful for
#           analyzing PSI-blast results.
#           These are ultimately added to the iteration object in end_iteration().
#
# Strategy:
#   Primary split = old vs. new
#   Secondary split = below vs. above threshold
#   1. Has this hit occurred in a previous iteration?
#   1.1. If yes, was it below threshold?
#   1.1.1. If yes, ---> [oldhits_below]
#   1.1.2. If no, is it now below threshold?
#   1.1.2.1. If yes, ---> [oldhits_newly_below]
#   1.1.2.2. If no, ---> [oldhits_not_below]
#   1.2. If no, is it below threshold?
#   1.2.1. If yes, ---> [newhits_below]
#   1.2.2. If no, ---> [newhits_not_below]
#   1.2.3. If don't know (no inclusion threshold data), ---> [newhits_unclassified]
#   Note: As long as there's a default inclusion threshold,
#         there won't be an unclassified set.
#
# For the first iteration, it might be nice to detect non-PSI blast reports
# and put the hits in the unclassified set.
# However, it shouldn't matter where the hits get put for the first iteration
# for non-PSI blast reports since they'll get flattened out in the
# result and iteration search objects.

sub _store_hit {
    my ($self, $hit, $hit_name, $hit_signif) = @_;

    my $ithresh = $self->{'_inclusion_threshold'};

    # This is the assumption leading to Bug 1986. The assumption here is that
    # the hit name is unique (and thus new), therefore any subsequent encounters
    # with a hit containing the same name are filed as old hits. This isn't
    # always true (see the bug report for a few examples). Adding an explicit
    # check for the presence of iterations, adding to new hits otherwise.

    if (exists $self->{'_old_hit_names'}->{$hit_name}
        && scalar @{$self->{_iterations}}) {
        if (exists $self->{'_hit_names_below'}->{$hit_name}) {
            push @{$self->{'_oldhits_below'}}, $hit;
        } elsif ($hit_signif <= $ithresh) {
            push @{$self->{'_oldhits_newly_below'}}, $hit;
        } else {
            push @{$self->{'_oldhits_not_below'}}, $hit;
        }
    } else {
        if ($hit_signif <= $ithresh) {
            push @{$self->{'_newhits_below'}}, $hit;
        } else {
            push @{$self->{'_newhits_not_below'}}, $hit;
        }
    }
    $self->{'_hitcount'}++;
}

1;
