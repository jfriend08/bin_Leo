#!/usr/bin/perl -w
#this code is use for making comprehensive information like kgXref. 
use 5.010;

#my $TuschlFile = shift;
my $ensemblFile = shift;

my @ID2=0;
my @ensemblInfo=0;
my @ensemblID=0;
#my @transcript1=0;
#my @transcript2=0;
#my $readlength=50;


#print "$ID2[0]\n";
#print "$ID2[1]\n";
#print "$ID2[3]\n";
open (ENSEMBL, $ensemblFile) or die "cannot open file: $ensemblFile";
@ensemblfile = <ENSEMBL>;
close ENSEMBL;
for ($i=0; $i<@ensemblfile; $i++){
    chomp $ensemblfile[$i];
    my @test=split ("\t",$ensemblfile[$i]);
    $test[0]= 'chr'.$test[0];
    my @test2= split (/";/,$test[9]);
    $test2[0]=substr $test2[0], 9; #gene_id
    $test2[1]=substr $test2[1], 16; #transcript_id
    $test2[2]=substr $test2[2], 14; #exon_number
    $test2[3]=substr $test2[3], 12; #gene_name
    $test2[4]=substr $test2[4], 15; #gene_biotype
    $test2[5]=substr $test2[5], 18; #transcript_name    
    $ensemblInfo[$i] = join("\t",$test[0],$test[1],$test[2],$test[3],$test[4],$test[5],$test[6],$test[7],$test[8],@test2);
    my @test3=split ("\t",$ensemblInfo[$i]);
    #    print "$test[9]\t$test[10]\n";
    my $sampleID =$test3[10];
    #    print "$ID\n";
    if ($FJR{$sampleID})  #geneID transcriptID
    {
        push (@{$FJR{$sampleID}}, join(",", $test3[0], $test3[1], $test3[2], $test3[9], $test3[3], $test3[4], $test3[5], $test3[11]));
    }
    else
    {
        push (@{$FJR{$sampleID}}, join(",", $test3[0], $test3[1], $test3[2], $test3[9], $test3[3], $test3[4], $test3[5], $test3[11]));
    }
}

for my $key (keys %FJR)
{
    print "$key\t";
    my $dist=0;
    my @value= @{$FJR{$key}};
    for ($j=0;$j<@value;$j++){
        my @test=split (",",$value[$j]);
        if ($j==0){
            print "$test[0]\t$test[3]\t$test[4]\t$test[5]\t$test[6]";
        }
        $dist = $dist + $test[2] - $test[1];
    }
    print "$dist\n";

}
exit;
