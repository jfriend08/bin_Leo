#!/usr/bin/perl -w

#delet the first Nth line and save it to other file
#deLines.pl <orginal file> <Nth line> <other file name1> <other file name2>

my $FileName = shift;
print "the original file name is: $FileName\n";
my $Nth = shift;
print "the line you like to delet is: $Nth\n";
my $otherFileName1 = shift;
print "you like to save it as: $otherFileName1\n";
my $otherFileName2 = shift;
print "you like to save it as: $otherFileName2\n";

my %chimericID=();
my $ID=0;

# import the chimeric SAM file and preprocess it as hash with multiple value
open(GENE_FILE, $FileName) or die "Cannot open $FileName" ;
@File=<GENE_FILE>;
print "$File[0]\n";

for ($i=0;$i<$Nth+1;$i++)
{
    print "$i\n";
    chomp $File[$i];
    $otherFile[$i]=$File[$i];
    if ($i>0)
    {
        delete $File[$i];
    }
}


$filename1 = "$otherFileName1";
$filename2 = "$otherFileName2";
open (OUT1, ">$filename1");
open (OUT2, ">$filename2");

for ($i=0;$i<@otherFile;$i++)
{
    print OUT1 "$otherFile[$i]\n";
}
close OUT1;

for ($i=0;$i<@File;$i++)
{
    chomp $File[$i];
    print OUT2 "$File[$i]\n";
}
close OUT2;

exit;


