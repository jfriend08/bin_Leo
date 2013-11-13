#!/bin/bash
#for i in $(ls -d *)
#do
#    cd $i
#    CURRENT=$(pwd); echo $CURRENT
#    cd "$i"_SAMfile
#    printf "\nMake symbolic link\n"
#    cat $"$i"_notbothSSRs_substr_sort.mrf | head -n 27 > ./mrf.header &  ## Assuming that the header has 27 lines
#    sed '1,27d' "$i"_notbothSSRs_substr_sort.mrf > "$i"_notbothSSRs_substr_sort.2.mrf &
#    cd ..
#    cd ..
#done
#wait

for i in $(ls -d *)
do
    cd $i
    CURRENT=$(pwd); echo $CURRENT
    cd "$i"_SAMfile
    printf "\ncat mrf lines\n"
    cat "$i"_notbothSSRs_substr_sort.2.mrf 1>>/aslab_scratch001/asboner_dat/PeterTest/NovalTAR2/compositAll.mrf
    cd ..
    cd ..
done
wait

#for i in $(ls -d *)
#do
#    cd $i
#    CURRENT=$(pwd); echo $CURRENT;
#    mkdir "$i"_BGRfile
#    cd "$i"_SAMfile
#    printf "\nStart mrf2bgr $i\n"
#    cat "$i"_alignmentNogene4_substr_sort.mrf | mrf2bgr "$i"_alignmentNogene4_substr_sort &
#    mv $(ls "$i"_alignmentNogene4_substr_sort_*.bgr) $CURRENT/"$i"_BGRfile &
#    cd ..
#    cd ..
#done
#wait

#for i in $(ls -d *)
#do
#    cd $i
#    CURRENT=$(pwd); echo $CURRENT;
#    cd  "$i"_BGRfile
#    printf "\nStart bgrSegmenter $i\n"
#    bgrSegmenter "$i"_alignmentNogene4_substr_sort 0.8 150 75 > "$i"_alignmentNogene4_substr_sort_segment_.bed &
#    cd ..
#    cd ..
#done
#wait




