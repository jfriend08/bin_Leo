#!/usr/bin/perl -w
## usage: WhiteListFilter.pl ME35_3_WhiteList.txt /home/ys486/lib/TICdb_WhiteList.txt

my $SampleFile = shift;
print "your sample ID is: $SampleFile\n";
my $WhiteFile = shift;
print "your white list file is: $WhiteFile\n";
open (SAMPLE_FILE1,$SampleFile) or die  "Cannot open $SampleFile";
my @SampleFile=<SAMPLE_FILE1>;
close SAMPLE_FILE1;
##Open and save the fusion candidate from the sample list
for ($i=0;$i<@SampleFile;$i++)
{
    chomp $SampleFile[$i];
    my @test=split("\t",$SampleFile[$i]);
    $ID1[$i]=$test[27];   ## In this case, candidates are save in the 27th and 28th column
    $ID2[$i]=$test[28];
}
open (SAMPLE_FILE2,$WhiteFile) or die  "Cannot open $WhiteFile";
my @WhiteFile=<SAMPLE_FILE2>;
close SAMPLE_FILE2;
for ($i=0;$i<@WhiteFile;$i++)
{
    chomp $WhiteFile[$i];
    my @test2=split("\t",$WhiteFile[$i]);
    $WhiteList_t1[$i]=$test2[0];  ## In this case, the WhiteList is based on TICdb database, and the translocation genes are saved in the 1st and 2nd column
    $WhiteList_t2[$i]=$test2[1];
    $WhiteList_ref[$i]=$test2[2];
}

$filename1 = "WhiteList.txt";
open (OUT1, ">$filename1");

## 2(sample list)x2 (WhiteList) matching
print OUT1 "MatchLoop    ID1 ID2 WhiteList1  WhiteList2  WhiteListRef\n";
for ($i=0;$i<@ID1;$i++)
{
    for ($j=0;$j<@WhiteList_t1;$j++)
    {
           if ($ID1[$i] =~ /$WhiteList_t1[$j]/g)
           {
               print OUT1 "match1    $ID1[$i]    $ID2[$i]    $WhiteList_t1[$j]    $WhiteList_t2[$j]   $WhiteList_ref[$j]\n";
           }
    }
    
    for ($k=0;$k<@WhiteList_t2;$k++)
    {
            if ($ID1[$i] =~ /$WhiteList_t2[$k]/g)
            {
                print OUT1 "match2    $ID1[$i]   $ID2[$i]    $WhiteList_t1[$k]    $WhiteList_t2[$k]   $WhiteList_ref[$k]\n";
            }
    }
}

for ($i=0;$i<@ID2;$i++)
{
    for ($j=0;$j<@WhiteList_t1;$j++)
    {
        if ($ID2[$i] =~ /$WhiteList_t1[$j]/g)
        {
            print OUT1 "match3   $ID1[$i]    $ID2[$i] $WhiteList_t1[$j]    $WhiteList_t2[$j]   $WhiteList_ref[$j]\n";
        }
    }
    
    for ($k=0;$k<@WhiteList_t2;$k++)
    {
        if ($ID2[$i] =~ /$WhiteList_t2[$k]/g)
        {
            print OUT1 "match4   $ID1[$i]    $ID2[$i] $WhiteList_t1[$k]    $WhiteList_t2[$k]   $WhiteList_ref[$k]\n";
        }
    }
}
close OUT1;
exit;
