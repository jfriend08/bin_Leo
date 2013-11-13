#!/usr/bin/perl -w
use 5.010;
#print "To use samFlagSubstract.pl, type samFlagSubstract.pl <file> <#column> <substract what>\n";

my $directory = shift;
my $samFile = shift;
my $gfrFile = shift;

my @T1=0;
my @T2=0;
my @transcript1=0;
my @transcript2=0;
my $readlength=50;

print "hi\n";

open (GFRFILE, $gfrFile) or die "cannot open file: $gfrFile";
@gfrfile = <GFRFILE>;
close GFRFILE;

for ($i=0; $i<@gfrfile; $i++){
    chomp $gfrfile[$i];
    @test=split ("\t",$gfrfile[$i]);
    $T1[0]=$test[11];
    $T1[1]=$test[13];
    $T1[2]=$test[14];
    $T2[0]=$test[18];
    $T2[1]=$test[20];
    $T2[2]=$test[21];
    $transcript1[$i] = join("\t",$T1[0],$T1[1],$T1[2]);
    $transcript2[$i] = join("\t",$T2[0],$T2[1],$T2[2]);
}

use Cwd;
my $pwd = getcwd;
chdir("$directory");
my @header=0;
open (SAMFILE, $samFile) or die "cannot open file: $samFile";
@samfile = <SAMFILE>;
chdir($pwd);

#   $i is gfr for loop
#   $j is FJR.sam for loop
for ($i=0;$i<@transcript1;$i++){
    @T1=split ("\t",$transcript1[$i]);
    @T2=split ("\t",$transcript2[$i]);
    @gfr=split ("\t",$gfrfile[$i]);
    for ($j=25;$j<@samfile;$j++){  
        if ($samfile[$j] =~m/\t$T1[0]\t/ && $samfile[$j] =~m/\t$T2[0]\t/ | $samfile[$j] =~m/\t=\t/){
            @test=split ("\t",$samfile[$j]);
            if (($test[3]>$T1[1] && $test[3]<$T1[2] && $test[7]>$T2[1] && $test[7]<$T2[2]) | ($test[7]>$T1[1] && $test[7]<$T1[2] && $test[3]>$T2[1] && $test[3]<$T2[2])){
                $geneID=join ("\t",$gfr[27],$gfr[28]);
                if ($FJR{$geneID})
                {
                    push (@{$FJR{$geneID}}, ["$test[0]", "$test[2]", "$test[3]", "$test[5]", "$test[6]", "$test[7]", "$test[9]"]);
                }
                else
                {
                    push (@{$FJR{$geneID}}, ["$test[0]", "$test[2]", "$test[3]", "$test[5]", "$test[6]", "$test[7]", "$test[9]"]);
                }
            }
        }
    }
}

for my $key (keys %FJR){
    my @value = @{$FJR{$key}};
        for ($i=0; $i<@gfrfile; $i++){
            chomp $gfrfile[$i];
            @gfr=split ("\t",$gfrfile[$i]);
            if (join("\t",$gfr[27],$gfr[28]) =~m/$key/){
                print "$key\n";
                 @value = sort {$b->[3] cmp $a->[3]|| $a->[2] <=> $b->[2]} @value;
                for $aref (@value){
                    shift @$aref;
                    #                    print "@$aref\n";
                    @test= split /[MS]/, @$aref[2];
                    $string1 = substr @$aref[5], 0, $test[0];
                    $string1_sub = substr $string1, 0, 5;
                    $string2 = substr @$aref[5], $test[0], $test[1];
                    $string2_sub = substr $string2, 0, 5;
                    pop @$aref;
                    push (@$aref, scalar reverse ("$string1_sub"), scalar reverse($string1));
                    push (@$aref, $string2_sub, $string2);
                }
                @value = sort {$b->[6] cmp $a->[6] || $a->[7] cmp $b->[7]|| $a->[2] cmp $b->[2]} @value;
                #                @value = sort {$b->[5] cmp $a->[5] || $a->[7] cmp $b->[7]} @value;
                #                @value = sort {$b->[5] cmp $a->[5] || $b->[6] cmp $a->[6] || $a->[2] cmp $b->[2] } @value;
                for $aref (@value){
                    #                    @$aref[5]= scalar reverse("@$aref[5]");
                    #                    say "@$aref";
                    #                    print "@$aref[0]\t@$aref[1]\t@$aref[2]\t@$aref[3]\t@$aref[4]\t";
                    for ($j=0;$j< $readlength -length(@$aref[6]);$j++){
                        print " ";
                    }
                    #                    my $tmp_merge = join(@$aref[6],@$aref[7]);
                    @$aref[6] = scalar reverse(@$aref[6]);
                    print "@$aref[6] @$aref[8]\n";
                }
            }
        }
}

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


sub DNA_sub{
    my ($dna)= @_;
    $dna =~ tr/ATCG/TAGC/;
    return $dna;
}


sub expand{
    my $dna=@_;
    my $seq = substr $dna, 0, 5;
    print "seq is: $seq\n";
    return $seq;
}
exit;



