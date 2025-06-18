# Nucleotide-diversity
The allopolyploid genome of Xenopus laevis behaves like a functional diploid in extant  populations

## Nucleotide Diversity

This page hold the script(s) used for the nucleotide diverity analysis 
### Step 1: Extract First/Last & SE Exon Positions
```
perl ParseGFF_First_LastExon.pl XENLA_9.2_Xenbase.gff
```

### Step 2: Run nucleotide diversity
For First Exon
```
perl Run_VCF.pl First_Exon_XENLA_9.2_Xenbase.gff.txt
```
For Last Exon
```
perl Run_VCF.pl Last_Exon_XENLA_9.2_Xenbase.gff.txt
```

For SE Exon
```
perl Run_VCF.pl Single_Exon_XENLA_9.2_Xenbase.gff.txt
```
