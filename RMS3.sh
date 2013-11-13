#!/bin/bash

## preparing .meta file for scoring candidates
#for i  in $(ls -d *)
#do
#    echo $i
#    cd $i
#    MAPPED=$(grep -v "AlignmentBlock" "$i"_chim_Align_merged.mrfSort.mrf | grep -v ^# | wc -l)
#    printf "Mapped_reads\t%d\n" $MAPPED>"$i"_chim_Align_merged.mrfSort.meta
#    cd ..
#done
#wait

##split the mrf files because genefusions cannot take all reads at once
#for i in $(ls -d *)
#do
#    cd $i
#    mkdir split &
#    MAPPED=$(cat $"$i"_chim_Align_merged.mrfSort.meta | cut -f2);echo $MAPPED & ## this reads the number of mapped reads from the meta file.
#    cat $"$i"_chim_Align_merged.mrfSort.mrf | head -n 28 > split/mrf.header &  ## Assuming that the header has 28 lines
#    let N="40000000";echo $N & ### this determines how many lines to include in each file. Please note that in this case, there are 28 lines as header, adjust this number accordingly
#    cat $"$i"_chim_Align_merged.mrfSort.mrf | split -d -l $N - split/$"$i"_chim_Align_merged.mrfSort""_ & ## the file will be generated into the split directory
#    cd ..
#done
#wait

#for i in $(ls -d *)
#do
#    printf "\nhello\n"
#    cd $i
#    CURRENT=$(pwd)
#    cd split/
#    printf "\n$(pwd)\n"
#    mv "$i"_chim_Align_merged.mrfSort_00 "$i"_chim_Align_merged.mrfSort""_00.mrf
#    cat mrf.header "$i"_chim_Align_merged.mrfSort_01>$"$i"_chim_Align_merged.mrfSort_01.mrf
#    cat mrf.header "$i"_chim_Align_merged.mrfSort_02>$"$i"_chim_Align_merged.mrfSort_02.mrf
#    cat mrf.header "$i"_chim_Align_merged.mrfSort_03>$"$i"_chim_Align_merged.mrfSort_03.mrf
#    cat mrf.header "$i"_chim_Align_merged.mrfSort_04>$"$i"_chim_Align_merged.mrfSort_04.mrf
#    rm $"$i"_chim_Align_merged.mrfSort_01
#    rm $"$i"_chim_Align_merged.mrfSort_02
#    rm $"$i"_chim_Align_merged.mrfSort_03
#    rm $"$i"_chim_Align_merged.mrfSort_04

#    cd ..
#    cd ..
#done
#wait


## geneFusions
##The first command (geneFusions) will create the first list of candidate fusion transcripts:
for i in $(ls -d *)
do
printf "\nhey\n"
cd $i
geneFusions "$i"_chim_Align_merged.mrfSort_00 4 <split/"$i"_chim_Align_merged.mrfSort_00.mrf>split/"$i"_chim_Align_merged.mrfSort_00.1.gfr 2>split/"$i"_chim_Align_merged.mrfSort_00.1.gfr.log &
geneFusions "$i"_chim_Align_merged.mrfSort_01 4 <split/"$i"_chim_Align_merged.mrfSort_01.mrf>split/"$i"_chim_Align_merged.mrfSort_01.1.gfr 2>split/"$i"_chim_Align_merged.mrfSort_01.1.gfr.log &
geneFusions "$i"_chim_Align_merged.mrfSort_02 4 <split/"$i"_chim_Align_merged.mrfSort_02.mrf>split/"$i"_chim_Align_merged.mrfSort_02.1.gfr 2>split/"$i"_chim_Align_merged.mrfSort_02.1.gfr.log &
geneFusions "$i"_chim_Align_merged.mrfSort_03 4 <split/"$i"_chim_Align_merged.mrfSort_03.mrf>split/"$i"_chim_Align_merged.mrfSort_03.1.gfr 2>split/"$i"_chim_Align_merged.mrfSort_03.1.gfr.log &
geneFusions "$i"_chim_Align_merged.mrfSort_04 4 <split/"$i"_chim_Align_merged.mrfSort_04.mrf>split/"$i"_chim_Align_merged.mrfSort_04.1.gfr 2>split/"$i"_chim_Align_merged.mrfSort_04.1.gfr.log &
cd ..
done
wait

for i in $(ls -d *)
do
printf "\nStart zipping gfr files\n"
cd $i/split
gzip $(ls *gfr)
cd ..
cd ..
done
wait
