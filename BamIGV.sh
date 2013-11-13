#!/bin/bash

#sam to bam
#for i in $(ls -d *)
#do
#    cd $i
#    cd "$i"_SAMfile
#    printf "\nStart sam to bam\n"
#    samtools view -S -h -b -@8 "$i"_ChimericPE.sam_F256_filtered.sam>"$i"_ChimericPE.sam_F256_filtered.bam &
#    samtools view -S -h -b -@8 "$i"_Aligned.out_F256_filtered.sam>"$i"_Aligned.out_F256_filtered.bam &
#    samtools view -S -h -b -@8 "$i"_chim_Align_merged.sam>"$i"_chim_Align_merged.bam &
#    samtools view -S -h -b -@8 FJR.sam>"$i"_FJR.bam &
#    cd ..
#    cd ..
#done
#wait

##Sorting
#for i in $(ls -d *)
#do
#    cd $i
#    cd "$i"_SAMfile
#    printf "\nStart sorting\n"; echo $i
#    samtools sort -@8 "$i"_ChimericPE.sam_F256_filtered.bam "$i"_ChimericPE.sam_F256_filtered_samSort &
#    samtools sort -@8 "$i"_Aligned.out_F256_filtered.bam "$i"_Aligned.out_F256_filtered_samSort &
#    samtools sort -@8 "$i"_FJR.bam "$i"_FJR_samSort &
#    cd ..
#    cd ..
#done
#wait

##Indexing
for i in $(ls -d *)
do
    cd $i/
    cd "$i"_SAMfile
    printf "\nStart indexing\n"; echo $i
    samtools index "$i"_ChimericPE.sam_F256_filtered_samSort.bam &
    samtools index "$i"_Aligned.out_F256_filtered_samSort.bam &
#    samtools index "$i"_chim_Aligned.out_F256_filtered_samSort &
    samtools index "$i"_FJR_samSort.bam &
    cd ..
    cd ..
done
wait



