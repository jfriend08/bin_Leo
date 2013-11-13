#!/usr/bin/perl -w

# usage: findFJRII.pl <directory/of/FJR/and/sorted.bam> <FJR.sam> <Alignmed.sorted.bam> <.fgr>
# example: findFJRII.pl /aslab_scratch001/asboner_dat/PeterTest/FinishedSamples/AS182_1/AS182_1_SAMfile/ FJR.sam AS182_1_Aligned.out_F256_filtered_samSort.bam AS182_1_chim_Align_merged.mrfSort.confidence.classify.gfr > test1.txt

# Note: this is the version that can rescu more FJR reads from normal aligned file. The input must have to be sorted bam format.
# Note: to have accurate FJR to rescu, you can play with $match_tmp and $match_tmp2. so far seems using 8 sequences would have a optimal result.
# Note: rescuring the FJR only baed on all candidates in .fjr is computational intensed, and will get lots of reads that are no FJR. therefore the idea for rescueing FJR is based on the fusion candidates having "typical FJR", and rescue and select the reads based on the info of typical FJR.

#To Do:  $geneID=join ("\t",$gfr[26],$gfr[27]), it may have different format of gfr

use Cwd;
my $directory = shift;
my $samFile = shift;
my $sortedBamFile = shift;
my $gfrFile = shift;
my @transcript1=0;
my @transcript2=0;
my $match_string='';  #to store few sequence at the fusion junction
my %matchSeq_list=(); #to store few sequence at the fusion junction
my %Location1=();
my %Location2=();


open (GFRFILE, $gfrFile) or die "cannot open file: $gfrFile";
@gfrfile = <GFRFILE>;
close GFRFILE;

for ($i=0; $i<@gfrfile; $i++){
    chomp $gfrfile[$i];
    @test=split ("\t",$gfrfile[$i]);
    $transcript1[$i] = join("\t",$test[11],$test[13],$test[14]);
    $transcript2[$i] = join("\t",$test[18],$test[20],$test[21]);
}

my $pwd = getcwd;
chdir("$directory");
my @header=0;
open (SAMFILE, $samFile) or die "cannot open file: $samFile";
@samfile = <SAMFILE>;
chdir($pwd);
############################################################################################################################################
# 1. to find the typical FJR
# 2. to store some junction sequence (8 letters) from FJR, and will use these letter to rescue accurate FJR from normal_alignmed
for ($i=0;$i<@transcript1;$i++){ #for loop of the gfr file
    @T1=split ("\t",$transcript1[$i]);
    @T2=split ("\t",$transcript2[$i]);
    @gfr=split ("\t",$gfrfile[$i]);
    for ($j=0;$j<@samfile;$j++){  #for loop of the FJR file
        #        if ($samfile[$j] =~m/\t$T1[0]\t/ && $samfile[$j] =~m/\t$T2[0]\t/ | $samfile[$j] =~m/\t=\t/){
        if ($samfile[$j] =~m/\t$T1[0]\t/ && $samfile[$j] =~m/\t$T2[0]\t/){
            @test=split ("\t",$samfile[$j]);
            if (($test[3]>$T1[1] && $test[3]<$T1[2] && $test[7]>$T2[1] && $test[7]<$T2[2]) | ($test[7]>$T1[1] && $test[7]<$T1[2] && $test[3]>$T2[1] && $test[3]<$T2[2])){
                $geneID=join ("\t",$gfr[26],$gfr[27]);

                if ($test[5] =~ m/[0-9][0-9][MS][0-9][0-9][MS]/){
                    my @tmp2= split /[MS]/, $test[5];
                    my $match_tmp = substr $test[9], $tmp2[0], 8;  # substract 6 letter for rescuring the FJR reads
                    my $match_tmp2 = substr $test[9], $tmp2[0]-9, 8;
                    my $match_tmp_anti = DNA_anti(scalar reverse ($match_tmp));
                    my $match_tmp2_anti = DNA_anti(scalar reverse ($match_tmp2));
                    if (($match_string !~ m/$match_tmp/) && ($match_string !~ m/$match_tmp_anti/)){
                        $match_string= join ("\t", $match_string, $match_tmp);
                    }
                    if (($match_string !~ m/$match_tmp2/) && ($match_string !~ m/$match_tmp2_anti/)){
                        $match_string= join ("\t", $match_string, $match_tmp2);
                    }
                }
                $matchSeq_list{$geneID} =$match_string;
                push (@{$FJR{$geneID}},join("\t",$test[9]));
            }
        }
    }
}

#for my $key (keys %matchSeq_list){
#    my $value = $matchSeq_list{$key};
    #    my $value2 = $matchSeq_list2{$key};
#    print "$key\t$value\n";
    #    print "$key\t$value2\n";
#}
#exit;

############################################################################################################################################
#1. based on the fusion candidates having typical FJR reads, get all of the reads at that region
#2. collect reads having this pattern: m/^[0-9][0-9]M[0-9][0-9]S$/ or m/^[0-9][0-9]S[0-9][0-9]M$/
#3. collect the reads having the mateched junction sequence, and then saved into %FJR
#4. collect the interval info

chdir("$directory");
for ($i=1; $i<@transcript1;$i++){
    for my $key (keys %matchSeq_list){
        @T1=split ("\t",$transcript1[$i]);
        @T2=split ("\t",$transcript2[$i]);
        @gfr=split ("\t",$gfrfile[$i]);
        $geneID=join ("\t",$gfr[26],$gfr[27]);
        my @value = split("\t", $matchSeq_list{$key});

        if ($key =~ m/$geneID/){
            system ("samtools view $sortedBamFile $T1[0]:$T1[1]-$T1[2] >tmp1.txt");
            system ("samtools view $sortedBamFile $T2[0]:$T2[1]-$T2[2]>tmp2.txt");
            my $tmp_T1="tmp1.txt";
            my $tmp_T2="tmp2.txt";
            open (TMP1, $tmp_T1) or die "cannot open file: $tmp_T1";
            @tmp1=<TMP1>;
            open (TMP2, $tmp_T2) or die "cannot open file: $tmp_T2";
            @tmp2=<TMP2>;
            close TMP1;
            close TMP2;
            my @all_tmp = (@tmp1, @tmp2);
            for ($j=0; $j<@all_tmp; $j++){
                chomp $all_tmp[$j];
                @test= split ("\t", $all_tmp[$j]);
                if (($test[5]=~ m/^[0-9][0-9]M[0-9][0-9]S$/) | ($test[5]=~ m/^[0-9][0-9]S[0-9][0-9]M$/)){
                    for ($k=0; $k< @value; $k++){
                        if (($test[9] =~ m/$value[$k]/) | ($test[9] =~ m/DNA_anti(scalar reverse ($value[$k]))/) ){
                            push (@{$FJR{$geneID}},join("\t",$test[9]));
                            
                            if (($test[6] =~ m/=/) && ($test[2] =~ m/$gfr[11]/)){
                                my $tmp_name="$test[2]:$test[3]-$test[7]";
                                push (@{$Location1{$geneID}},join ("\t", $test[2], $test[3], $test[7]));
                            }
                            if (($test[6] =~ m/=/) && ($test[2] =~ m/$gfr[18]/)){
                                my $tmp_name="$test[2]:$test[3]-$test[7]";
                                push (@{$Location2{$geneID}}, join ("\t", $test[2], $test[3], $test[7]));
                            }
                        }
                    }
                    
                    
                }
            }
        }
    }
}
chdir($pwd);
############################################################################################################################################
# add new column to .gfr
$header=0;
for my $key (keys %FJR){
    my @value = @{$FJR{$key}};
        for ($i=0; $i<@gfrfile; $i++){
            chomp $gfrfile[$i];
            @gfr=split ("\t",$gfrfile[$i]);
           if ($i == 0 && $header==0){
                push @gfr, "FJR", "Interval";
		$header=1;
            }
            if (join("\t",$gfr[27],$gfr[28]) =~m/$key/){
                @LocationInterval1 = sort {$a cmp $b} @{$Location1{$key}};  #but the locations should be saved by order already
                @LocationInterval2 = sort {$a cmp $b} @{$Location2{$key}};
                push @gfr, join (">",@value);
                my @tmp_beginloc1= split("\t", $LocationInterval1[0]);
                my @tmp_lastloc1= split("\t", $LocationInterval1[-1]);
                my @tmp_beginloc2= split("\t", $LocationInterval2[0]);
                my @tmp_lastloc2= split("\t", $LocationInterval2[-1]);
                my $tmp_name= "$tmp_beginloc1[0]:$tmp_beginloc1[1]-$tmp_lastloc1[2]|$tmp_beginloc2[0]:$tmp_beginloc2[1]-$tmp_lastloc2[2]";
                push @gfr, $tmp_name;
            }
            $gfrfile[$i]=join ("\t",@gfr);
        }
}

# print out new .gfr file
foreach my $line (@gfrfile){
    print "$line\n";
}

sub DNA_anti{
    my ($dna)= @_;
    $dna =~ tr/ATCG/TAGC/;
    $dna =~ tr/atcg/tagc/;
    return $dna;
}

exit;
