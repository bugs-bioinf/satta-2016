#! /usr/local/bin/perl -w

use strict;
use warnings;
use POSIX;
use Getopt::Long;
use Pod::Usage;

use Bio::SeqIO;

###############################################################################
# Process command line options
#

my ( $gbkfile, $strand, $verbose, $help );

GetOptions(
           'gbk|g=s'    => \$gbkfile,
           'strand|s=s' => \$strand,
           'verbose'   => \$verbose,
           'help|?'    => \$help,
          ) or pod2usage(2);

# Defaults
#$strand ||= 'for';

pod2usage(-exitstatus => 0, -verbose => 2) if $help;
    
if ( $help || !$gbkfile || !$strand ) { pod2usage(1) }

###############################################################################

# set strand to 0/1
$strand = $strand eq 'for' ? 1 : -1;

print STDERR "Reading Genbank: ".$gbkfile."\n" if $verbose;

my $seqin = Bio::SeqIO->new( -format => 'genbank', -file => $gbkfile );

while ( my $seq = $seqin->next_seq() ) {
	my $id     = $seq->id;
	my $length = $seq->length;
	my $desc = $seq->description;

	my @features = $seq->all_SeqFeatures;

	foreach my $feature ( @features ) {
		
		my ($name, $gene, $locus_tag, $product);
      	
		my @tags = $feature->all_tags;
		
 #     	if ( $feature->primary_tag eq 'gene' ) {				
#			foreach my $tag ( @tags ) {
#				($gene)      = $feature->each_tag_value($tag) if $tag eq 'gene';
#				($locus_tag) = $feature->each_tag_value($tag) if $tag eq 'locus_tag';
#			}
			
#			$name = $locus_tag ? $locus_tag : $gene;
#		} els
		
		if ( $feature->primary_tag eq 'CDS' ) {
			foreach my $tag ( @tags ) {
				($gene)      = $feature->each_tag_value($tag) if $tag eq 'gene';
				($locus_tag) = $feature->each_tag_value($tag) if $tag eq 'locus_tag';
				($product)   = $feature->each_tag_value($tag) if $tag eq 'product';
			}
			
			$name = $locus_tag ? $locus_tag : $gene ? $gene : $product;
		}
		
		next unless $name;
		
		if ( $feature->strand eq $strand ) {
			print $id."\t".$feature->start."\t".$feature->end."\n";
		}
	}	
}









__END__

=head1 NAME

create_circos_track.pl - 

=head1 SYNOPSIS

create_circos_track.pl --bam <bam file> --gbk <genbank file>

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do something
useful with the contents thereof.

=head1 AUTHOR

Adam Witney <awitney@sgul.ac.uk>
BuG@S group, Deptartment of Cellular and Molecular Medicine,
St George's, University of London,
London, UK

=head1 COPYRIGHT

bugasbase_pars.pl is Copyright (c) 2009 Adam Witney. UK. All rights reserved.

You may distribute under the terms of either the GNU General Public License or the Artistic License, as specified in the Perl README file.

=cut
