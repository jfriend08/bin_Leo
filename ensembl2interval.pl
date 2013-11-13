#!/usr/bin/perl -w
use 5.010;

my $TuschlFile = shift;
my $ensemblFile = shift;

my @ID2=0;
my @ensemblInfo=0;
my @ensemblID=0;
#my @transcript1=0;
#my @transcript2=0;
#my $readlength=50;

open (TUSCHL, $TuschlFile) or die "cannot open file: $ensemblFile";
@TuschlFile = <TUSCHL>;
close TUSCHL;

for ($i=0; $i<@TuschlFile; $i++){
    chomp $TuschlFile[$i];
    @test=split ("\t",$TuschlFile[$i]);
    $ID2[$i] = join("\t",$test[0],$test[1],$test[2]);
    #    print "@ID\n";
}
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
    my $sampleID =join ("\t",$test3[9],$test3[10]);
    #    print "$ID\n";
    if ($FJR{$sampleID})  #geneID transcriptID
    {
        push (@{$FJR{$sampleID}}, join(",", $test3[0], $test3[1], $test3[2], $test3[3], $test3[4], $test3[5], $test3[11]));
    }
    else
    {
        push (@{$FJR{$sampleID}}, join(",", $test3[0], $test3[1], $test3[2], $test3[3], $test3[4], $test3[5], $test3[11]));
    }
}

for ($i=0; $i<@ID2; $i++){
    my @test = split ("\t", $ID2[$i]);
    
    my $ID4=join ("\t", $test[0], $test[2]);
    if ($FJR{$ID4}){
        my $starts='';
        my $ends='';
        my $dist=0;
        print "$test[2]\t";  #ensembl transcriptID
        #        print "${$FJR{$ID4}}[0]\n";
        my $numExon = scalar @{$FJR{$ID4}};
        for ($j=0;$j<@{$FJR{$ID4}};$j++)
        {
            my @tmp=split ("\t",${$FJR{$ID4}}[$j]);
            
            for ($k=0; $k<@tmp; $k++){
                my @tmp2=split(",",$tmp[$k]);
                if ($j ==0 && $k==0){
                    print "$tmp2[0]\t"; #chromosome
                    print "$tmp2[5]\t"; #strain
                    print "$tmp2[1]\t"; #left most
                }
                if ($j ==@{$FJR{$ID4}}-1 && $k==@tmp-1){
                    print "$tmp2[2]\t"; #right most
                }
                $dist = $dist + $tmp2[2] - $tmp2[1];
                
                $starts=join(",", $starts, $tmp2[1]);
                $ends=join(",", $ends, $tmp2[2]);
            }
        }
        $starts=substr $starts, 1; #gene_biotype
        $ends=substr $ends, 1; #transcript_name
        print "$numExon\t"; #number of exons
        print "$starts\t"; #start position of every exons
        print "$ends\n"; #end position of every exons
        print "$dist\n"; # not typical interval file. the total length of all exons
        delete $FJR{$ID4};
    }
}





exit;
