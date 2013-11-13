#!/bin/bash

##STAR alignment
##this time without outSAMunmapped specified
for i in $(ls -d *)
do
	cd $i
	printf "\nStart STAR alignment\n"
   star  --runThreadN 6 --outFileNamePrefix "$i"_ --genomeDir /pbtech_mounts/fdlab_store003/fdlab/genomes/human/hg19/indexes/star --chimSegmentMin 10 --readFilesIn "$(ls *R1*.fastq)" "$(ls *R2*.fastq)" &
	cd ..
done
wait

#--genomeLoad LoadAndRemove 