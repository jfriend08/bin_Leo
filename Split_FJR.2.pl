#!/usr/bin/perl -w

# To use Split_FJR.pl, type Split_FJR.pl <DATA.sam> <ID_list.txt>
# import the ID list and save it as an array

my $sam = shift;
print "your chimeric input is: $sam\n";
my $id_list = shift;
print "your ID_list is: $id_list\n";
my %chimericID=();
my $ID=0;

$ID_List = $id_list;
#$ID_List = 'ID_list.txt';
unless ( -e $ID_List)
{
print "$ID_List not exist\n";
exit;
}
unless (open(GENE_FILE, $ID_List) )
{
print "Cannot open $ID_List\n";
exit;
}
@ID = <GENE_FILE>;
close GENE_FILE;

for($i=0;$i<@ID;$i++)
{
    chomp $ID[$i];
}


# import the chimeric SAM file and preprocess it as hash with multiple value
$SAM_List = $sam;
#$SAM_List = 'Chimeric.out.sam';
unless ( -e $SAM_List)
{
    print "$SAM_List not exist\n";
    exit;
}
unless (open(GENE_FILE, $SAM_List) )
{
    print "Cannot open $SAM_List\n";
    exit;
}

@chimericSAM = <GENE_FILE>;
close GENE_FILE;
#print "$chimericSAM[24]and$chimericSAM[25]and$chimericSAM[26]andHAHA";
#exit;


for ($i=0;$i<26;$i++)
{
	chomp $chimericSAM[$i];
	$header[$i]= $chimericSAM[$i];
}


for($i=26;$i<@chimericSAM;$i++)
{
    chomp $chimericSAM[$i];
    @test=split ("\t",$chimericSAM[$i]);
    $firstID=shift @test;
    if ($chimericID{$firstID})
    {
        #asign the multiple value to the same key
        push (@{$chimericID{$firstID}},join("\t",@test));
    }
    else
    {
        push (@{$chimericID{$firstID}},join("\t",@test));
        #        $chimericID{$firstID}=join("\t",@test);
        #        print "Now the pushed hash is: @{$chimericID{$firstID}}\n";
        #        print "different loop now is $i\n";
        
    }
}

#loop of ID to save FJR to different file and delet FJR_ID from chimericSAM hash
$filename1 = "FJR.sam";
$filename2 = "chimericPE.sam";
open (OUT1, ">$filename1");
open (OUT2, ">$filename2");

for ($i=0;$i<26;$i++)
{
	print OUT1 "$header[$i]\n";
}


for ($i=0;$i<@ID;$i++)
{
    if ($chimericID{$ID[$i]})
    {
        foreach (@{$chimericID{$ID[$i]}})
        {
            print OUT1 "$ID[$i]\t";
            print OUT1 "$_\n";
        }
        delete $chimericID{$ID[$i]};
    }
    else
    {
        print "not match $i\n";
    }
}
close OUT1;

#to print out the rest of chimericSAM hash
#foreach (@{$chimericID{$ID[$i]}})
for ($i=0;$i<26;$i++)
{
	print OUT2 "$header[$i]\n";
}

for my $key (keys %chimericID)
{
    my @value= @{$chimericID{$key}};
    foreach $line (@value)
    {
         print OUT2 "$key\t";
         print OUT2 "$line\n";
    }
}
close OUT2;
exit;

