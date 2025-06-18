#!/usr/bin/perl -w
use strict;
############################################################
# Objective: Subset and calculate the nucleotide Diversity

############################################################

my $BedFile= $ARGV[0];   #"First_Exon_XENLA_9.2_Xenbase.gff.txt";
my $VCF="Xenopus_Blue_NoHyb.vcf.gz";
my $SI=0; 
my $Flanking=10000;
#my $Flanking=0;
open HNS,">Average_sites_PI_$BedFile";
open HN,"<$BedFile";
while(<HN>)
{
	chomp;
	my($GeneID,$ExonChr,$FExonStart,$FExonEnd,$FID)=(split "\t",$_);
	$SI++;
	next if ($SI==1);
	my $Len=$FExonEnd-$FExonStart;
	#print "\n\n$ExonChr:$FExonStart-$FExonEnd\t$Len\n";
	$FExonStart=$FExonStart-$Flanking;$FExonStart=1 if($FExonStart<1);
	$FExonEnd=$FExonEnd+$Flanking;
	my $window_pi=$FExonEnd-$FExonStart;
	$window_pi*=10;
	#print "$GeneID\_$FID\t$ExonChr:$FExonStart-$FExonEnd\t$window_pi\n";
	#print "bcftools filter -r $ExonChr:$FExonStart-$FExonEnd $VCF >$GeneID\_$FID.vcf\n";
	system("bcftools filter -r $ExonChr:$FExonStart-$FExonEnd $VCF >$GeneID\_$FID.vcf");
	
	system("vcftools --vcf $GeneID\_$FID.vcf --site-pi --out $GeneID\_$FID");
	`awk '\$3!~/-nan/ {print \$0}' $GeneID\_$FID\.sites.pi >>$GeneID\_$FID\.clean.sites.pi`;

	my $AVG=`awk '{ sum += \$3 } END { if (NR > 0) print sum / NR }' $GeneID\_$FID\.clean.sites.pi`;
	chomp($AVG);
	print HNS"$GeneID\_$FID\t$ExonChr\t$AVG\n";
	unlink("$GeneID\_$FID.sites.pi");
	unlink("$GeneID\_$FID.vcf");
	unlink("$GeneID\_$FID.log");
	unlink("$GeneID\_$FID.clean.sites.pi");
#	last if($SI==5);

}
close(HN);




