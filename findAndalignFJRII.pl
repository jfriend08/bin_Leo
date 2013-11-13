#!/usr/bin/perl -w

# usage: findAndalignFJRII.pl <read length> <directory/of/FJR/and/sorted.bam> <FJR.sam> <Alignmed.sorted.bam> <.fgr>
# example: findAndalignFJRII.pl 75 /aslab_scratch001/asboner_dat/PeterTest/test_Samples/testIII/ AS182_FJR.sam AS182_sorted.bam AS182_1_chim_Align_merged.mrfSort.confidence.classify.gfr

# Note: this is the version that can collect typical FJR, rescue FJR from Alignmed.sorted.bam, and align all the FJR reads.
# Note: the rationale for this tool is collecting all FJR reads in opportunite order (all reads are correlected as chrX xxMxxS), then sorted by -5-0 of junction sequence, then sorted by mateched length (xxM),  then sorted by 0-5 of junction sequence.

use 5.010;
use Cwd;
my $readlength=shift;
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
        #        if ($samfile[$j] =~m/\t$T1[0]\t/ && $samfile[$j] =~m/\t$T2[0]\t/ | $samfile[$j] =~m/\t=\t/)
        if ($samfile[$j] =~m/\t$T1[0]\t/ && $samfile[$j] =~m/\t$T2[0]\t/){
            @test=split ("\t",$samfile[$j]);
            if (($test[3]>$T1[1] && $test[3]<$T1[2] && $test[7]>$T2[1] && $test[7]<$T2[2]) | ($test[7]>$T1[1] && $test[7]<$T1[2] && $test[3]>$T2[1] && $test[3]<$T2[2])){
                $geneID=join ("\t",$gfr[26],$gfr[27]);
                
                if ($test[5] =~ m/[0-9][0-9][MS][0-9][0-9][MS]/){
                    my @tmp2= split /[MS]/, $test[5];
                    my $match_tmp = substr $test[9], $tmp2[0], 7;  # substract 6 letter for rescuring the FJR reads
                    my $match_tmp2 = substr $test[9], $tmp2[0]-8, 7;
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
                
                if ($test[2] =~ m/$gfr[11]/){
                    push (@{$FJR{$geneID}}, ["$test[0]", "$test[2]", "$test[3]", "$test[5]", "$test[6]", "$test[7]", "$test[9]"]);
                }
                else {
                    $test[9]=DNA_anti(scalar reverse ($test[9]));
                    my @tmp = split /[MS]/, $test[5];
                    $test[5]="$tmp[1]M$tmp[0]S";
                    push (@{$FJR{$geneID}}, ["$test[0]", "$test[6]", "$test[7]", "$test[5]", "$test[2]", "$test[3]", "$test[9]"]);
                }
                #                push (@{$FJR{$geneID}}, ["$test[0]", "$test[2]", "$test[3]", "$test[5]", "$test[6]", "$test[7]", "$test[9]"]);
                #                push (@{$FJR{$geneID}},join("\t",$test[9]));
            }
        }
    }
}

#for my $key (keys %matchSeq_list){
##    my $value = $matchSeq_list{$key};
##    my $value2 = $matchSeq_list2{$key};
#    print "$key\n";
#    for $aref (@{$FJR{$key}}){
#        print "@$aref\n";
#    }
##    print "$key\t$value2\n";
#}
#exit;

############################################################################################################################################
#1. based on the fusion candidates having typical FJR reads, get all of the reads at that region
#2. collect reads having this pattern: m/^[0-9][0-9]M[0-9][0-9]S$/ or m/^[0-9][0-9]S[0-9][0-9]M$/
#3. collect the reads having the mateched junction sequence, and then saved into %FJR

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
                            
                            if ($test[2] =~ m/$gfr[11]/){
                                push (@{$FJR{$geneID}}, ["$test[0]", "$test[2]", "$test[3]", "$test[5]", "$test[6]", "$test[7]", "$test[9]"]);
                            }
                            else {
                                $test[9]=DNA_anti(scalar reverse ($test[9]));
                                my @tmp = split /[MS]/, $test[5];
                                $test[5]="$tmp[1]M$tmp[0]S";
                                push (@{$FJR{$geneID}}, ["$test[0]", "$test[6]", "$test[7]", "$test[5]", "$test[2]","$test[3]", "$test[9]"]);
                            }
                            
                            #push (@{$FJR{$geneID}}, ["$test[0]", "$test[2]", "$test[3]", "$test[5]", "$test[6]", "$test[7]", "$test[9]"]);
                            #                            push (@{$FJR{$geneID}},join("\t",$test[9]));
                        }
                    }
                    
                    
                }
            }
        }
    }
}
chdir($pwd);

#for my $key (keys %matchSeq_list){
##    my $value = $matchSeq_list{$key};
##    my $value2 = $matchSeq_list2{$key};
#    print "$key\n";
#    for $aref (@{$FJR{$key}}){
#        print "@$aref\n";
#    }
##    print "$key\t$value2\n";
#}
#exit;
##########################################################################################################################################
for my $key (keys %FJR){
    my @value = @{$FJR{$key}};
        for ($i=0; $i<@gfrfile; $i++){
            chomp $gfrfile[$i];
            @gfr=split ("\t",$gfrfile[$i]);
            if (join("\t",$gfr[27],$gfr[28]) =~m/$key/){
                print "$key\n";
                @value = sort {$b->[3] cmp $a->[3]|| $a->[2] <=> $b->[2]} @value;
                for $aref (@value){
                    #                    print "@$aref\n";
                    shift @$aref;
                    #                    print "@$aref\n";
                    @test= split /[MS]/, @$aref[2];
                    $string1 = substr @$aref[5], 0, $test[0];
                    $string2 = substr @$aref[5], $test[0], $test[1];
                    $forSorting1= substr scalar reverse ("$string1"), 0, 5; #collect some sequence for sorting purpose
                    $forSorting2= substr scalar reverse ("$string2"), 0, 5;
                    pop @$aref;
                    push (@$aref, scalar reverse ("$string1"), $string2, $forSorting1, $forSorting2);
                    #                    push (@$aref, $string2, $forSorting);
                }
                @value = sort {$b->[7] cmp $a->[7] || $a->[2] cmp $b->[2] || $b->[8] cmp $a->[8] } @value;
                for $aref (@value){
                    @$aref[5]= scalar reverse("@$aref[5]");
                    #say "@$aref";
                    #print "@$aref[0]\t@$aref[1]\t@$aref[2]\t@$aref[3]\t@$aref[4]\t";
                    for ($j=0;$j< $readlength -length(@$aref[5]);$j++){
                        print " ";
                    }
                    print "@$aref[5] @$aref[6]\n";
                }
            }
        }
}

##########################################################################################################################################
print "Which candidate to antisense? left(1)right(2)both(3)? A-BtoB-A(Y/N)\n";
print "Enter inputs separated by comma\n";
my $input = <STDIN>;
chomp $input;
exit 0 if ($input eq "");
my @all = split(/\,/, $input);
my $antisense =join ("\t", $all[0], $all[1]);
my $partner =$all[2];
my $inverse =$all[3];

my @value = @{$FJR{$antisense}};
for $aref (@value){
    @$aref[5]= scalar reverse("@$aref[5]");
}
@value = sort {$b->[5] cmp $a->[5] || $a->[2] cmp $b->[2] || $b->[6] cmp $a->[6] } @value;

    for $aref (@value){
        if ($inverse =~ m/N/){
            for ($j=0;$j<$readlength- length(@$aref[5]);$j++){
                print " ";
            }
            if ($partner == 1){
                @$aref[5]= DNA_sub (scalar reverse(@$aref[5]));
                print "@$aref[5] @$aref[6]\n";
            }
            if ($partner == 2){
                @$aref[6]= DNA_sub (@$aref[6]);
                print "@$aref[5] @$aref[6]\n";
            }
            if ($partner == 3){
                @$aref[5]= DNA_sub (scalar reverse(@$aref[5]));
                @$aref[6]= DNA_sub (@$aref[6]);
                print "@$aref[5] @$aref[6]\n";
            }

        }
        if ($inverse =~ m/Y/){
            for ($j=0;$j<$readlength- length(@$aref[6]);$j++){
                print " ";
            }
            if ($partner == 1){
                @$aref[5]= DNA_sub (scalar reverse(@$aref[5]));
                print "@$aref[6] @$aref[5]\n";
            }
            if ($partner == 2){
                @$aref[6]= DNA_sub (scalar reverse(@$aref[6]));
                print "@$aref[6] @$aref[5]\n";
            }
            if ($partner == 3){
                @$aref[5]= DNA_sub (@$aref[5]);
                @$aref[6]= DNA_sub (scalar reverse(@$aref[6]));
                print "@$aref[6] @$aref[5]\n";
            }
        }
    }

##########################################################################################################################################
sub DNA_anti{
    my ($dna)= @_;
    $dna =~ tr/ATCG/TAGC/;
    return $dna;
}

sub DNA_sub{
    my ($dna)= @_;
    $dna =~ tr/ATCG/TAGC/;
    return $dna;
}


exit;



