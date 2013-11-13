#!/bin/bash
for i in $(ls -d *)
do
    cd $i
    CURRENT=$(pwd); echo $CURRENT
    cd "$i"_MRFfile
    geneFusions "$i"_chim_Align_merged.mrfSort 4 < "$i"_chim_Align_merged.mrfSort.mrf > /aslab_scratch001/asboner_dat/PeterTest/NovalTAR2/"$i"_chim_Align_merged.mrfSort.NovalTAR.1.gfr &
    cd ..
    cd ..
done
wait


for i in $(ls -d *)
do
    cd $i
    CURRENT=$(pwd); echo $CURRENT
    cd "$i"_MRFfile
    gzip "$i"_chim_Align_merged.mrfSort &
    cd ..
    cd ..
done
wait