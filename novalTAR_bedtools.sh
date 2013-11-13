#!/bin/bash

#for i in $(ls -d *)
#do
#    cd $i
#    CURRENT=$(pwd);echo $CURRENT
#    cd "$i"_SAMfile
#    printf "\ncat bed files\n"
#    samtools cat "$i"_Aligned.out_F256_filtered.bam "$i"_chimericFJR.bam > "$i"_Aligned_Chim_FJR.bam &
#    cd ..
#    cd ..
#done
#wait

#sam to bam
for i in $(ls -d *)
do
    cd $i
    CURRENT=$(pwd);echo $CURRENT
    cd "$i"_SAMfile
    printf "\nStart intersectBed\n"
    pairToBed -abam "$i"_Aligned_Chim_FJR.bam -b /home/asboner/annotations/human/hg19/ucsc/knownGeneAnnotationTranscriptCompositeModel.bed -type notboth > "$i"_notbothSSRs.bam &
    cd ..
    cd ..
done
wait

for i in $(ls -d *)
do
    cd $i
    CURRENT=$(pwd); echo $CURRENT
    cd "$i"_SAMfile
    printf "\nStart bam to sam\n"
    samtools view -h "$i"_notbothSSRs.bam > "$i"_notbothSSRs.sam &
    cd ..
    cd ..
done
wait

for i in $(ls -d *)
do
    cd $i
    CURRENT=$(pwd); echo $CURRENT
    cd "$i"_SAMfile
    printf "\nStart samFlag substraction\n"
    samFlagSubstract.pl "$i"_notbothSSRs.sam 2 1 > "$i"_notbothSSRs_substr.sam &
    cd ..
    cd ..
done
wait

for i in $(ls -d *)
do
    cd $i
    CURRENT=$(pwd); echo $CURRENT
    cd "$i"_SAMfile
    printf "\nStart sam2mrf\n"
    cat "$i"_notbothSSRs_substr.sam |sam2mrf|mrfSorter>"$i"_notbothSSRs_substr_sort.mrf &
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




