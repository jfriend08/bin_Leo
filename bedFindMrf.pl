#!/usr/bin/perl -w

print "To use bedFindMrf.pl, type bedFindMrf.pl <DATA.mrf> <DATA.bed>\n";
# import the ID list and save it as an array

my $mrf = shift;
print "your mrf input is: $mrf\n";
my $bedFile = shift;
print "your Bed file is: $bedFile\n";

my @bed=0;
my @bedID=0;
my @allmrf=0;
my @header=0;
my %superMrf=();


open (MRF, $mrf) or die "cannot open file: $mrf";
open (BEDFILE, $bedFile) or die "cannot open file:$bedFile";

@bed = <BEDFILE>;
close BEDFILE;
print "hi, before makeing bedID\n";
for ($i=0; $i<@bed; $i++){
    chomp $bed[$i];
    @test=split ("\t",$bed[$i]);
    $bedID[$i]=substr($test[3], 0, -2);
}
print "hi, after makeing bedID\n";
# import the MRF file and preprocess it as hash with multiple value
@allmrf = <MRF>;
close MRF;


print "this is bedID[1]:$bedID[1]\n";
print "this is allmrf[1]:$allmrf[1]\n";

for ($i=0;$i<28;$i++)
{
	chomp $allmrf[$i];
	$header[$i]= $allmrf[$i];
}

for ($i=28;$i<@allmrf;$i++){
    chomp $allmrf[$i];
    @test=split ("\t", $allmrf[$i]);
    $ID=substr($test[3], 0, -2);
    #    print "$ID";
    $superMrf{$ID}=join("\t",@test);
}

$filename1 = "alignmentNogene.mrf";
open (OUT1, ">$filename1");

for ($i=0;$i<28;$i++){
    print OUT1 "$header[$i]\n";
}

for ($j=0;$j<@bedID;$j++){   #bedID loop
    if ($superMrf{$bedID[$j]}){
        print OUT1 "$superMrf{$bedID[$j]}\n";
        delete $superMrf{$bedID[$j]};
        }
}
close OUT1;

exit;



$filename1 = "alignmentNogene.mrf";
open (OUT1, ">$filename1");
for ($j=0;$j<@bedID;$j++){   #bedID loop
    for ($i=26;$i<@allmrf;$i++){    #allMrf loop
        if ($bedID[$j] =~/\Q$allmrf[$i]\E/g){
            print OUT1 "$allmrf[$i]\n";
            delete $allmrf[$i];
        }
    }
}
close OUT1;

exit;

