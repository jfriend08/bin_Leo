#!/usr/bin/perl -w
## Usage: ConciseList.pl <FileToConsice>
##A
##A
##A
##B         A
##B     =>  B
##C         C
##D         D
##D         E
##E

$list = shift;
#$ID_List = 'ID_list.txt';
open (SAMPLE_FILE,$list) or die "cannot open file $list";
my @list = <SAMPLE_FILE>;
close SAMPLE_FILE;

for($i=0;$i<@list;$i++)
{
    chomp $list[$i];
    my @array=split("\t",$list[$i]);
    $Transcript1[$i]=$array[0];
    $Transcript2[$i]=$array[1];
    $test[$i]=join("\t",$Transcript1[$i],$Transcript2[$i]);
}
#$test[$i]=join("\t", ($Transcript1[$i], $Transcript2[$i]));
print "$test[0]\n";

$filename='TICdb_concised.txt';
open (OUT,">$filename");
$i=0;
for ($j=0;$j<@test;$i++)
{
    if ($j==0)
    {
        print OUT "$test[$j]\n";
    }
    while ($test[$i] =~ /$test[$i+1]/g)
    {
        $i=$i+1;
    }
    $j=$i+1;
    print OUT "$test[$j]\n";
}
close OUT;
exit;