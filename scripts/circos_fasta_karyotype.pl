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

my ( $fasta, $tab, $verbose, $help );

GetOptions(
           'fasta|f=s'    => \$fasta,
           'tab|t=s'    => \$tab,
           'verbose'      => \$verbose,
           'help|?'       => \$help,
          ) or pod2usage(2);

# Defaults
# $qual_cutoff  ||= 30;

pod2usage(-exitstatus => 0, -verbose => 2) if $help;
    
if ( $help || !$fasta ) { pod2usage(1) }

###############################################################################

my $seqin = Bio::SeqIO->new( -format => 'Fasta', -file => $fasta );

while ( my $seq = $seqin->next_seq() ) {
	my $id     = $seq->id;
	my $length = $seq->length;
                
	print "chr\t-\t".$id."\t".$id."\t0\t".$length."\tchr1\n";
}

if ( $tab && -f $tab ) {

	print STDERR "\nChecking ".$tab."\n";
	
	open(TAB, $tab) || die "\nCannot open $tab: $!";
	
	my $start = 0;
	my $end   = 0;
	my $contig = '';
	
	while ( <TAB> ) {
		my $line = $_;
		chomp $line;
		
		if ( $line =~ m/FT.+?contig.+?(\d+)..(\d+)/ ) {
			$start = $1;
			$end = $2;
		} elsif ( $line =~ m/systematic_id="(.+?)"/ ) {
			$contig = $1;
			print "Q88\t".$start."\t".$end."\tid=".$contig."\n";
		}
	}
}

__END__

=head1 NAME

filter_vcf.pl - Filters VCF file based on various criteria

=head1 SYNOPSIS

filter_vcf.pl --vcf vcffile --chrom NC_009777

filter_vcf.pl --vcf vcffile1 --vcf vcffile2 --chrom NC_009777 --qual 30 --dp4 75 --dp 10 --dpmax 100 -af 0.75 --showfiltered --noindels --noheader --phylip 
	              --ignorefile Mobiles.txt --verbose

=head1 OPTIONS

  --vcf             Input VCF file
  --chrom           Reference sequence name to analyse (In case VCF is mapped against multiple sequences)
  --qual            Minimum QUAL score [30]
  --dp4             % reads supoprting SNP [0]
  --dp              Minimum read depth at site [0]
  --dpmax           Maximum read depth at site [100000]
  --af              Allele frequency cutoff e.g. 0.75 [0]
  --showfiltered    Also show all the sites removed (in a Filtered subsection at end),
                       useful to see how well filtering is performing
  --noindels        Filter out INDEL variants
  --phylip          Export data in phylip alignement format (may have to adjust sequence names)
  --ignorefile      Specify a text file containing coordinates of regions to ignore e.g. mobile elements
  --noheader        Do not print VCF header
  
  --verbose         print more information (not much at the moment!)
  
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

=head1 DISCLAIMER

This software comes with no warranty and you use it at your own risk. There may be bugs!

=cut