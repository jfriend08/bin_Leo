#!/usr/bin/perl -w
## usage: WhiteListFilter.3.pl <ME35_3_WhiteList.txt> <OutputName.whiteList.txt> <OutputName_TICdb.whiteList.gfr> <OutputName_cosmic.whiteList.gfr> <OutputName_mitelman.whiteList.gfr>
## WhiteListFilter.3.pl ME35_3_chim_Align_merged.mrfSort_remained_Info.1.gfr ME35_3.whiteList.txt ME35_3_TICdb.whiteList.gfr ME35_3_cosmic.whiteList.gfr ME35_3_mitelman.whiteList.gfr

my $gfr = shift;
print "your sample ID is: $gfr\n";
my $outputList = shift;
my $TICdb_whiteList = shift;
my $cosmic_whiteList = shift;
my $mitelman_whiteList = shift;
my $WhiteFile1 = '/home/ys486/lib/whiteList.TICdb.txt';
my $WhiteFile2 = '/home/ys486/lib/whiteList.cosmic.v58.txt';
my $WhiteFile3 = '/home/ys486/lib/whiteList.mitelman.txt';
print "your white list file is: $WhiteFile1\n";
open (GFR,$gfr) or die  "Cannot open $SampleFile";
my @gfr=<GFR>;
close GFR;
##Open and save the fusion candidate from the sample list
for ($i=0;$i<@gfr;$i++)
{
    chomp $gfr[$i];
    my @test0=split("\t",$gfr[$i]);
    $ID1[$i]=$test0[26];   ## In this case, candidates are save in the 27th and 28th column
    $chr1[$i]=$test0[11];
    $ID2[$i]=$test0[27];
    $chr2[$i]=$test0[18];
}
#print "$chr2[2]  $chr1[2]\n";
#print "$ID1[10]   $ID2[10]\n";
#print "$gfr[10]\n";   #@gfr is here
#exit;

## open TICdb data
open (DATA_FILE1,$WhiteFile1) or die  "Cannot open $WhiteFile1";
my @WhiteFile1=<DATA_FILE1>;
close DATA_FILE1;
for ($i=0;$i<@WhiteFile1;$i++)
{
    chomp $WhiteFile1[$i];
    my @test=split("\t",$WhiteFile1[$i]);
    $WhiteList_t1[$i]=$test[0];
    $WhiteList_t2[$i]=$test[1];
}


## open cosmic data
open (DATA_FILE2,$WhiteFile2) or die  "Cannot open $WhiteFile1";
my @WhiteFile2=<DATA_FILE2>;
close DATA_FILE2;
for ($i=0;$i<@WhiteFile2;$i++)
{
    chomp $WhiteFile2[$i];
    my @test2=split("\t",$WhiteFile2[$i]);
    $cosmicList_t1[$i]=$test2[0];
    $cosmicList_t2[$i]=$test2[1];
}


## open mitelman data
open (DATA_FILE3,$WhiteFile3) or die  "Cannot open $WhiteFile1";
my @WhiteFile3=<DATA_FILE3>;
close DATA_FILE3;
for ($i=0;$i<@WhiteFile3;$i++)
{
    chomp $WhiteFile3[$i];
    my @test3=split("\t",$WhiteFile3[$i]);
    $mitelmanList_t1[$i]=$test3[0];
}


$filename1 = $outputList;
$filename2 = $TICdb_whiteList;
$filename3 = $cosmic_whiteList;
$filename4 = $mitelman_whiteList;
open (OUT1, ">$filename1");
open (OUT2, ">$filename2");
open (OUT3, ">$filename3");
open (OUT4, ">$filename4");

#####################Compare with TICdb###################
print OUT1 "TICdb\n";
print OUT1 "Database    MatchLoop   Chr_1   ID1 Chr_2   ID2 WhiteList1  WhiteList2  \n";
print OUT2 "$gfr[0]\n";
for ($i=0;$i<@ID1;$i++)
{
        for ($j=0;$j<@WhiteList_t1;$j++)
        {
               if ($ID1[$i] =~ /\Q$WhiteList_t1[$j]\E/g)
               {
                   print OUT1 "TICdb    match1  $chr1[$i]   $ID1[$i]    $chr2[$i]   $ID2[$i]    $WhiteList_t1[$j]   $WhiteList_t2[$j]\n";
                   print OUT2 "$gfr[$i]\n";
               }
        }
        for ($k=0;$k<@WhiteList_t2;$k++)
        {
                if ($ID1[$i] =~ /\Q$WhiteList_t2[$k]\E/g)
                {
                    print OUT1 "TICdb   match2  $chr1[$i]   $ID1[$i]    $chr2[$i]   $ID2[$i]    $WhiteList_t1[$k]   $WhiteList_t2[$k]\n";
                    print OUT2 "$gfr[$i]\n";
                }
        }
}

for ($i=0;$i<@ID2;$i++)
{
    for ($j=0;$j<@WhiteList_t1;$j++)
    {
        if ($ID2[$i] =~ /\Q$WhiteList_t1[$j]\E/g)
        {
            print OUT1 "TICdb   match3  $chr1[$i]   $ID1[$i]    $chr2[$i]   $ID2[$i]    $WhiteList_t1[$j]   $WhiteList_t2[$j]\n";
            print OUT2 "$gfr[$i]\n";
        }
    }
    
    for ($k=0;$k<@WhiteList_t2;$k++)
    {
        if ($ID2[$i] =~ /\Q$WhiteList_t2[$k]\E/g)
        {
            print OUT1 "TICdb   match4  $chr1[$i]   $ID1[$i]    $chr2[$i]   $ID2[$i]    $WhiteList_t1[$k]   $WhiteList_t2[$k]\n";
            print OUT2 "$gfr[$i]\n";
        }
    }
}
close OUT2;
###################Compare with cosmic#############
print OUT1 "cosmic\n";
print OUT1 "Database    MatchLoop   Chr_1   ID1 Chr_2   ID2 WhiteList1  WhiteList2  \n";
print OUT3 "$gfr[0]\n";
for ($i=0;$i<@ID1;$i++)
{
    for ($j=0;$j<@cosmicList_t1;$j++)
    {
        if ($ID1[$i] =~ /\Q$cosmicList_t1[$j]\E/g)
        {
            print OUT1 "cosmic  match1  $chr1[$i]   $ID1[$i]    $chr2[$i]   $ID2[$i]    $cosmicList_t1[$j]  $cosmicList_t2[$j]\n";
            print OUT3 "$gfr[$i]\n";
        }
    }
    for ($k=0;$k<@cosmicList_t2;$k++)
    {
        if ($ID1[$i] =~ /\Q$cosmicList_t2[$k]\E/g)
        {
            print OUT1 "cosmic  match2  $chr1[$i]   $ID1[$i]    $chr2[$i]   $ID2[$i]    $cosmicList_t1[$k]  $cosmicList_t2[$k]\n";
            print OUT3 "$gfr[$i]\n";
        }
    }
}
for ($i=0;$i<@ID2;$i++)
{
    for ($j=0;$j<@cosmicList_t1;$j++)
    {
        if ($ID2[$i] =~ /\Q$cosmicList_t1[$j]\E/g)
        {
            print OUT1 "cosmic  match3  $chr1[$i]   $ID1[$i]    $chr2[$i]   $ID2[$i]    $cosmicList_t1[$j]  $cosmicList_t2[$j]\n";
            print OUT3 "$gfr[$i]\n";
        }
    }
    
    for ($k=0;$k<@cosmicList_t2;$k++)
    {
        if ($ID2[$i] =~ /\Q$cosmicList_t2[$k]\E/g)
        {
            print OUT1 "cosmic  match4  $chr1[$i]   $ID1[$i]    $chr2[$i]   $ID2[$i]    $cosmicList_t1[$k]  $cosmicList_t2[$k]\n";
            print OUT3 "$gfr[$i]\n";
        }
    }
}
close OUT3;
###################Compare with cosmic#############
print OUT1 "mitelman\n";
print OUT1 "Database    MatchLoop   Chr_1   ID1 Chr_2   ID2 WhiteList1  WhiteList2  \n";
print OUT4 "$gfr[0]\n";
for ($i=0;$i<@ID1;$i++)
{
    for ($j=0;$j<@mitelmanList_t1;$j++)
    {
        if ($ID1[$i] =~ /\Q$mitelmanList_t1[$j]\E/g || $mitelmanList_t1[$j] =~ /\Q$ID1[$i]\E/g)
            {
                print OUT1 "mitelman    match1  $chr1[$i]   $ID1[$i]    $chr2[$i]   $ID2[$i]    $mitelmanList_t1[$j]\n";
                print OUT4 "$gfr[$i]\n";
            }
    }
}
for ($i=0;$i<@ID2;$i++)
{
    for ($j=0;$j<@mitelmanList_t1;$j++)
    {
        if ($ID2[$i] =~ /\Q$mitelmanList_t1[$j]\E/g || $mitelmanList_t1[$j] =~ /\Q$ID1[$i]\E/g)
        {
            print OUT1 "mitelman    match3  $chr1[$i]   $ID1[$i]    $chr2[$i]   $ID2[$i]    $mitelmanList_t1[$j]\n";
            print OUT4 "$gfr[$i]\n";
        }
    }
}
close OUT4;
close OUT1;

exit;
