#!/bin/bash
##This is the step for unzip the files

#for i  in $(ls -d *)
#do
#	cd $i
#	printf "\n $i start unzip\n"
#    gzip -d "$(ls *R1*fastq.gz)" &
#    gzip -d "$(ls *R2*fastq.gz)" &
#	cd ..
#done
#wait

#for i  in $(ls -d *)
#    do
#    cd $i
#    printf "\nStart fastqc\n"
#    /home/ys486/PROGRAMS/FastQC/fastqc $(ls *R1*fastq)
#    /home/ys486/PROGRAMS/FastQC/fastqc $(ls *R2*fastq)
#    cd ..
#done
#wait

##STAR alignment
##this time without outSAMunmapped specified
for i in $(ls -d *)
do
	cd $i
	printf "\n$i Start STAR alignment\n"; echo $(pwd)
  star  --genomeLoad LoadAndKeep --runThreadN 8 --outFileNamePrefix "$i"_ --genomeDir /pbtech_mounts/fdlab_store003/fdlab/genomes/human/hg19/indexes/star --chimSegmentMin 10 --readFilesCommand zcat --readFilesIn "$(ls *R1*fastq.gz)" --outFilterScoreMinOverLread 0.85 &
#   star  --genomeLoad LoadAndKeep --runThreadN 5 --outFileNamePrefix "$i"_ --genomeDir /pbtech_mounts/fdlab_store003/fdlab/genomes/human/hg19/indexes/star --chimSegmentMin 10 --readFilesCommand zcat --readFilesIn "$(ls *R1*fastq.gz)" "$(ls *R2*fastq.gz)" &
	cd ..
done
wait

## move the zip files
#for i  in $(ls -d *)
#do
#    cd $i
#    printf "\nMove zip\n"
#    mv "$(ls *R1*fastq.gz)" /aslab_scratch001/asboner_dat/PeterTest/DataSet/Run4 &
#    mv "$(ls *R2*fastq.gz)" /aslab_scratch001/asboner_dat/PeterTest/DataSet/Run3/$i &
#    cd ..
#done
#wait

for i in $(ls -d *)
do
    grep p $i/"$i"_Chimeric.out.junction | cut -f 10 >"$i"/"$i"_ID_list.txt &
done
wait

for i in $(ls -d *)
do
	cd $i
    Split_FJR.2.pl "$i"_Chimeric.out.sam "$i"_ID_list.txt
	cd ..
done
wait

for i in $(ls -d *)
do
	samtools view -S -h -F 256 -@8 $i/"$i"_Aligned.out.sam >$i/"$i"_Aligned.out_F256_filtered.sam &
	samtools view -S -h -F 256 -@8 $i/chimericPE.sam >$i/"$i"_ChimericPE.sam_F256_filtered.sam &
done
wait

##Merge the files of chimericPE and Align
for i in $(ls -d *)
do
cd $i
printf "\nstart merging chimericPE and Align files, time is:\n"
java -Xmx4g -jar /pbtech_mounts/homesA/asboner/Software/picard-tools-1.85/MergeSamFiles.jar SORT_ORDER=queryname TMP_DIR=/aslab_scratch001/asboner_dat/PeterTest/STAROutput/tmp_dir MAX_RECORDS_IN_RAM=1000000 INPUT="$i"_Aligned.out_F256_filtered.sam INPUT="$i"_ChimericPE.sam_F256_filtered.sam OUTPUT=$"$i"_chim_Align_merged.sam 1>>mergesamFile.log 2>>mergesamFile.err.log &
cd ..
done
wait

for i in $(ls -d *)
do
    cd $i

    cat "$i"_Aligned.out_F256_filtered.sam|sam2mrf|mrfSorter|gzip>"$i"_Aligned.out_F256_filtered.mrf &
    cd ..
done
wait


#for i in $(ls -d *)
#do
#    cd $i
#    printf "\n"$i"\n"
#    zcat $(ls *mrf.gz)|mrfQuantifier ~/hg19/ensembl_EwingMerged_GRCh37.73.interval multipleOverlap > ./"$i"_ensembl_merged_geneExpr.txt &
#    cd ..
#done
#wait


