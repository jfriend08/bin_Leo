#!/usr/bin/perl -w

print "To use Split_FJR.pl, type Split_FJR.pl <DATA.sam> <DATA.bed>\n";
# import the ID list and save it as an array

my $sam = shift;
print "your chimeric input is: $sam\n";
my $bedFile = shift;
print "your Bed file is: $bedFile\n";

my %chimericID=();
my @bed=0;
my @bedID=0;

open (SAM, "<", $sam) or die "cannot open file: $sam";
open (BEDFILE, $bedFile) or die "cannot open file:$bedFile";

@bed = <BEDFILE>;
close BEDFILE;

for ($i=0; $i<@bed; $i++){
    chomp $bed[$i];
    @test=split ("\t",$bed[$i]);
    $bedID[$i]=substr($test[3], 0, -2);
}

# import the chimeric SAM file and preprocess it as hash with multiple value
@chimericSAM = <SAM>;
close GENE_FILE;
for ($i=0;$i<26;$i++)
{
	chomp $chimericSAM[$i];
	$header[$i]= $chimericSAM[$i];
}
for($i=26;$i<@chimericSAM;$i++)
{
    chomp $chimericSAM[$i];
    @test=split ("\t",$chimericSAM[$i]);
    $firstID=shift @test;
    if ($chimericID{$firstID})
    {
        #asign the multiple value to the same key
        push (@{$chimericID{$firstID}},join("\t",@test));
    }
    else
    {
        push (@{$chimericID{$firstID}},join("\t",@test));
    }
}

#loop of ID to save FJR to different file and delet FJR_ID from chimericSAM hash
$filename1 = "alignmentNogene.sam";
open (OUT1, ">$filename1");

for ($i=0;$i<26;$i++)
{
	print OUT1 "$header[$i]\n";
}

for ($i=0;$i<@bedID;$i++)
{
    if ($chimericID{$bedID[$i]})
    {
        foreach (@{$chimericID{$bedID[$i]}})
        {
            print OUT1 "$bedID[$i]\t";
            print OUT1 "$_\n";
        }
        delete $chimericID{$bedID[$i]};
    }
    else
    {
        print "not match $i $bedID[$i]\n";
    }
}
close OUT1;
exit;
