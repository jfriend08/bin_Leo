#!/usr/bin/perl -w
## Usage: ConciseList.pl <FileToConsice>
$list = shift;
#$ID_List = 'ID_list.txt';
open (SAMPLE_FILE,$list) or die "cannot open file $list";
my @list = <SAMPLE_FILE>;
close SAMPLE_FILE;

for($i=0;$i<@list;$i++)
{
    chomp $list[$i];
    #   print "$list[$i]\n";
    #    my @array=split("\t",$list[$i]);
}
#$test[$i]=join("\t", ($Transcript1[$i], $Transcript2[$i]));
#print "$test[1000]\n";
@test=@list;
#print "$test[100]\n";
#exit;

$filename='mitelman_concised.txt';
open (OUT,">$filename");
$i=0;
for ($j=0;$j<@test;$i++)
{
    if ($j==0)
    {
        print OUT "$test[$j]\n";
    }
    while ($test[$i]=~/\Q$test[$i+1]\E/g)
    {
        print "$i\n";
        $i=$i+1;
    }
    $j=$i+1;
    print OUT "$test[$j]\n";
}
close OUT;
exit;