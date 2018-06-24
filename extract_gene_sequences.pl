#!/usr/bin/perl


use strict;
use warnings;


my $input_gene_file = $ARGV[0]; # sample_ackA_results.txt
my $assembly_summary_file = "/home/ec2-user/assembly_summary.txt"; 
#ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt
my %tax_ids;
my %tax_id_assembly_paths;


## gets all unique tax_ids
open(my $IN,"<",$input_gene_file) || die $!;
while(<$IN>){
	next if($_=~/^tax/);
	my @line = split(/\t/,$_);
	$tax_ids{$line[0]}[0] = $line[11]; # genomic_nucleotide_accession
	$tax_ids{$line[0]}[1] = $line[12]; # start position
	$tax_ids{$line[0]}[2] = $line[13]; # stop position
}
close($IN);


## stores all assembly paths per tax_ids
open(my $ASF,"<",$assembly_summary_file) || die $!;
while(<$ASF>){
	my $l = $_;
	chomp($l);
	next if($l=~/^\#/);
	my @line = split(/\t/,$l);
	if(exists $tax_ids{$line[5]}){
		push(@{$tax_id_assembly_paths{$line[5]}},$line[19]);
	}
}
close($ASF);


## downloads all assembly paths of interest ---> https://www.ncbi.nlm.nih.gov/genome/doc/ftpfaq/#allcomplete
foreach my $tax_id (keys %tax_id_assembly_paths){
	foreach(@{$tax_id_assembly_paths{$tax_id}}){
		my $ftp_path = $_;
		if($_=~/.*?\/(GCF_.*)/){
			$ftp_path = $ftp_path . "/" . $1 . "_genomic.fna.gz";
		}
		`wget $ftp_path`;
		`gunzip $ftp_path`;	
	}
}








