#!/bin/bash


##This is the step for unzip the files
for i  in $(ls -d *)
do
	cd $i
	printf "\start wc\n"
    zcat $(ls *R1*fastq.gz)|wc -l>>"$i"_wc.txt &
    zcat $(ls *R2*fastq.gz)|wc -l>>"$i"_wc.txt &
	cd ..
done
wait
