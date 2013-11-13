#!/usr/bin/perl -w

#print "To use samFlagSubstract.pl, type samFlagSubstract.pl <file> <#column> <substract what>\n";

my $file = shift;
#print "your file is: $file\n";
my $column = shift;
#print "column to substract: $column\n";
my $number = shift;
#print "number: $number\n";

my @header=0;
open (FILE, $file) or die "cannot open file: $file";

@file = <FILE>;
close FILE;
for ($i=0; $i<26; $i++){
    chomp $file[$i];
    $header[$i]=$file[$i];
}

for ($i=26; $i<@file; $i++){
    chomp $file[$i];
    @test=split ("\t",$file[$i]);
    $test[$column-1]=$test[$column-1]-$number;
    $file[$i]= join("\t",@test);
}

#$filename1 = "alignmentNogene4_subst.sam";
#open (OUT1, ">$filename1");

for ($i=0;$i<26;$i++){
    #    print OUT1 "$header[$i]\n";
    print "$header[$i]\n";
}

for ($i=26;$i<@file;$i++){   #bedID loop
    #    print OUT1 "$file[$i]\n";
    print "$file[$i]\n";
}
#close OUT1;

exit;
