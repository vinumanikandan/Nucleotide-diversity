#!/usr/bin/perl -w
use strict;
#################################
# Update Feb 26 2024
# Parse and Consider only First and last Exon for a gene irrespective of the isoform
#######################################

my $Input=$ARGV[0];

##################################### Variables #####################################################
my ($GID,$gene_biotype,$gene,$mRNID,$mRNAGeneID,$ExonID,$ExonmRNAID)=("","","","","","","");
my %GeneInfo=();	my %mRNAInfo=();	my %ExonInfo=();
#####################################################################################################


open HN,"<$Input";
while(<HN>)
{
	chomp;
	next if((/^\s*#.*/)||(/^\s*Scaffold.*/));
	my($chr,$Xenbase,$type,$start,$end,$dot,$strand,$dot2,$info)=(split "\t",$_);
	if($type eq "gene")
	{
		my(@arr)=(split ";",$info);
		foreach my $in(sort @arr)
		{
			$GID =$1 if($in=~/ID\=(\S+)/);
			$gene_biotype =$1 if($in=~/gene_biotype\=(\S+)/);
			$gene=$1 if($in=~/gene\=(\S+)/);
		}
		$GeneInfo{$GID}="$chr\t$start\t$end\t$gene\t$gene_biotype"
	}
	elsif($type eq "mRNA")
        {
		my(@arr)=(split ";",$info);
                foreach my $in(sort @arr)
                {
			$mRNID=$1 if($in=~/ID\=(\S+)/);
			$mRNAGeneID=$1 if($in=~/Parent\=(\S+)/);
		}
			if(defined $mRNAInfo{$mRNAGeneID})
			{
				$mRNAInfo{$mRNAGeneID}.=",$mRNID"
			}	
			else
			{
				$mRNAInfo{$mRNAGeneID}="$mRNID"
			}
	}
	elsif ($type eq "exon")
	{
		#print "$info\n";
		my(@arr)=(split ";",$info);
                foreach my $in(sort @arr)
                {
                        $ExonID=$1 if($in=~/ID\=(\S+)/);
                        $ExonmRNAID=$1 if($in=~/Parent\=(\S+)/);
                }

		if(defined $ExonInfo{$ExonmRNAID})
                        {
                                $ExonInfo{$ExonmRNAID}.=",$ExonID;$chr;$start;$end"
                        }
                        else
                        {
                                $ExonInfo{$ExonmRNAID}="$ExonID;$chr;$start;$end"
                        }
	}

}
close(HN);

my $SI=0;
open HNSE,">Last_Exon_$Input\.txt";
open HNSF,">First_Exon_$Input\.txt";
open HNSS,">Single_Exon_$Input\.txt";
print HNSF "GeneID\tChr\tStart\tEnd\tExonID\n";
print HNSE "GeneID\tChr\tStart\tEnd\tExonID\n";
print HNSS "GeneID\tChr\tStart\tEnd\tExonID\n";
foreach my $GeneID(keys %GeneInfo)
{
	if(defined $mRNAInfo{$GeneID})
        {
		#print "$GeneID\t$GeneInfo{$GeneID}\n";
	    my $FExonStart=0; my $FExonEnd=0; my $FID='';
	    my $LExonStart=0; my $LExonEnd=0; my $LID='';
	    my $ExonChr='';

	     foreach my $mRNA(split ",",$mRNAInfo{$GeneID})
     		{
			 #print "\t$mRNA\n";
		  foreach my $Exon(split ",",$ExonInfo{$mRNA})
        	  {
			#print "\t$Exon\n";
			my($ExonID,$chr,$start,$end)=(split ";",$Exon);
			 $ExonChr=$chr;
			if($FExonStart == 0)
			{
				 $FExonStart=$start;
				 $FExonEnd=$end;
				 $FID=$ExonID;
			}
			if($start<$FExonStart)
			{
				$FExonStart=$start;
				$FExonEnd=$end;
				$FID=$ExonID;
			}
			if($LExonStart == 0)
                        {
                                 $LExonStart=$start;
                                 $LExonEnd=$end;
                                 $LID=$ExonID;
                        }
                        if($end>$LExonEnd)
                        {
                                $LExonStart=$start;
                                $LExonEnd=$end;
                                $LID=$ExonID;
                        }
		

		  }
     		}
		
		if($LID ne $FID)
		{
			print HNSF"$GeneID\t$ExonChr\t$FExonStart\t$FExonEnd\t$FID\n";
			print HNSE"$GeneID\t$ExonChr\t$LExonStart\t$LExonEnd\t$LID\n";
		}
		else
		{
			 print HNSS"$GeneID\t$ExonChr\t$FExonStart\t$FExonEnd\t$FID\n";
		}
	}
	$SI++;
}


