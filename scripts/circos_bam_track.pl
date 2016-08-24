#! /usr/local/bin/perl -w

use strict;
use warnings;
use POSIX;
use Getopt::Long;
use Pod::Usage;

use Bio::DB::Sam;

use constant DUMP_INTERVAL => 1_000_000;

###############################################################################
# Process command line options
#

my ( $bamfile, $window, $verbose, $help );

GetOptions(
           'bam|b=s'    => \$bamfile,
           'window|w=s' => \$window,
           'verbose'    => \$verbose,
           'help|?'     => \$help,
          ) or pod2usage(2);

# Defaults
$window  ||= 100;

pod2usage(-exitstatus => 0, -verbose => 2) if $help;
    
if ( $help || !$bamfile  ) { pod2usage(1) }

###############################################################################

print STDERR "Reading BAM: ".$bamfile."\n" if $verbose;;

my $sam = Bio::DB::Sam->new(-bam  => $bamfile); #, -fasta=>$fafile);

my @seq_ids = $sam->seq_ids;

print STDERR "\tFound ".@seq_ids." sequences\n\n" if $verbose;

my $avg_coverage;
my $total_length;

my $counter1 = 0;
my $counter2 = 0;

my $start = 0;
my $end = 0;

foreach my $seq_id ( sort @seq_ids ) {

	print STDERR "\t".$seq_id."\n";

	my ($coverage) = $sam->features(-type => 'coverage', -seq_id => $seq_id);
	my @coverage_data = $coverage->coverage;

	for ( my $i = 0; $i < @coverage_data; $i += $window ) {
		my $start = $i;
		my $end = $i + $window - 1;

		my @data = @coverage_data[$start..$end];
		@data = map { $_ ? $_ : 0 } @data;

		if ( @data ) {
			my $mean = eval(join("+", @data)) / @data;
		
			printf("%s\t%d\t%d\t%.1f\n", $seq_id, $start, $end, $mean);
		} else {
			print STDERR "\nEnd of data\n";
		}
#		if ( $i > 1000 ) { exit(0) }
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
