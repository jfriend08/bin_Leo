#!/usr/bin/perl -w

#print "To use samFlagSubstract.pl, type samFlagSubstract.pl <file> <#column> <substract what>\n";

my $directory = shift;
my $samFile = shift;
#print "your samfile is: $samFile\n";
my $gfrFile = shift;
#print "your gfrfile is: $gfrFile\n";

my @T1=0;
my @T2=0;
my @transcript1=0;
my @transcript2=0;

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
#print "pwd is: $pwd\n";
chdir("$directory");
my @header=0;
open (SAMFILE, $samFile) or die "cannot open file: $samFile";
@samfile = <SAMFILE>;
chdir($pwd);

for ($i=0;$i<@transcript1;$i++){ #for loop of the gfr file
    @T1=split ("\t",$transcript1[$i]);
    @T2=split ("\t",$transcript2[$i]);
    @gfr=split ("\t",$gfrfile[$i]);
    for ($j=25;$j<@samfile;$j++){  #for loop of the FJR file
        if ($samfile[$j] =~m/\t$T1[0]\t/ && $samfile[$j] =~m/\t$T2[0]\t/ | $samfile[$j] =~m/\t=\t/){
            @test=split ("\t",$samfile[$j]);
            if (($test[3]>$T1[1] && $test[3]<$T1[2] && $test[7]>$T2[1] && $test[7]<$T2[2]) | ($test[7]>$T1[1] && $test[7]<$T1[2] && $test[3]>$T2[1] && $test[3]<$T2[2])){
                print "$gfr[27]\t$gfr[28]\t$test[0]\t$test[2]\t$test[3]\t$test[5]\t$test[6]\t$test[7]\t$test[9]\n";
                $geneID=join ("\t",$gfr[27],$gfr[28]);
                if ($FJR{$geneID})
                {
                    push (@{$FJR{$geneID}},join("\t",$test[0],$test[2],$test[3],$test[5],$test[6],$test[7],$test[9]));
                }
                else
                {
                    push (@{$FJR{$geneID}},join("\t",$test[0],$test[2],$test[3],$test[5],$test[6],$test[7],$test[9]));

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
                #                push @gfr, join (">",@value);
                print "$key\n";
                foreach my $line (@value){
                    my @element = split("\t",$line);
                    my $locationID=join ("\t", $element[2], $element[5])
                    #if ($Location{$locationID}){
                        push (@{$Location{$locationID}},join("\t",@element));
                    #}
                    #else{
                    #    push (@{$Location{$locationID}},join("\t",@element));
                    #}


                    
                    #                    if ($gfr[11] !~ m/\t$gfr[18]\t/){
                    #                        if ($element[1] =~ m/$gfr[11]/){
                    #                            print "0\t$gfr[11]\t$element[2]\t$element[3]\t$element[6]\n";
                    #                            print "$element[4]\t$element[5]\t$element[6]\n";
                    #                        }
                    #                        if ($element[1] =~ m/$gfr[18]/){
                    #                            print "1\t$gfr[18]\t$element[2]\t$element[3]\t$element[6]\n";
                    #                            print "$element[4]\t$element[5]\t$element[6]\n";
                    #                        }
                    #                    }
                    #                    else{
                    #                        print "$element[1]\t$element[2]\t$element[3]\n";
                    #                        print "$element[4]\t$element[5]\n";
                    #                        print "$element[6]\n";
                    #                    }
                    
                }
                print "\n";
            }
            #            $gfrfile[$i]=join ("\t",@gfr);
        }
}

exit;

foreach my $line (@gfrfile){
    print "$line\n";
}

exit;