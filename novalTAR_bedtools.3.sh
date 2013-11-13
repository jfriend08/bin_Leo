#!/bin/bash

    CURRENT=$(pwd); echo $CURRENT;
    mkdir BGRfile
    printf "\nStart mrf2bgr $i\n"
    cat compositAll.mrf | mrf2bgr compositAll_notbothSSRs_substr_sort &
    mv $(ls mrf2bgr compositAll_alignmentNogene4_substr_sort_*.bgr) $CURRENT/"$i"_BGRfile &
done
wait

    CURRENT=$(pwd); echo $CURRENT;
    cd  "$i"_BGRfile
    printf "\nStart bgrSegmenter $i\n"
    bgrSegmenter compositAll_alignmentNogene4_substr_sort 0.5 150 75 > compositAll_alignmentNogene4_substr_sort_segment1_.bed &
    bgrSegmenter compositAll_alignmentNogene4_substr_sort 0.8 150 75 > compositAll_alignmentNogene4_substr_sort_segment2_.bed &
    bgrSegmenter compositAll_alignmentNogene4_substr_sort 1.1 150 75 > compositAll_alignmentNogene4_substr_sort_segment3_.bed &
    cd ..
done
wait




