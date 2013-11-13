#!/bin/bash

##This is the step for unzip the files
#for i  in $(ls -d *)
#do
#	cd $i
#	printf "\nstart unzip, time is:\n"
	##nohup unzip $i &
#    gunzip "$(ls *R1*.fastq.gz)" &
#    gunzip "$(ls *R2*.fastq.gz)" &
#	cd ..
#done
#wait

##STAR alignment
##this time with outSAMunmapped specified
#for i in $(ls -d *)
#do
#	cd $i
#	printf "\nStart STAR alignment, time is :\n"
#	time star  --runThreadN 6 --outFileNamePrefix "$i"_  --outSAMunmapped Within --genomeDir /pbtech_mounts/fdlab_store003/fdlab/genomes/human/hg19/indexes/star --chimSegmentMin 10 --readFilesIn "$(ls *R1*.fastq)" "$(ls *R2*.fastq)" &
#	cd ..
#done
#wait


#for i in $(ls -d *)
#do
#	printf "\nstart creating ID_list, time is:\n"
#	time grep p $i/"$i"_Chimeric.out.junction | cut -f 10 >"$i"/"$i"_ID_list.txt &
#done
#wait

#for i in $(ls -d *)
#do
#	cd $i
#	printf "\nstart spliting chimeric output, time is:\n"
#	time Split_FJR.pl "$i"_Chimeric.out.sam "$i"_ID_list.txt
#	cd ..
#done
#wait

#for i in $(ls -d *)
#do
#	printf "i is : $i\n"
#	printf "\nstart samtools filtering, time is:\n"
#	time samtools view -S -h -F 256 $i/"$i"_Aligned.out.sam >$i/"$i"_Aligned.out_F256_filtered.sam &
#	time samtools view -S -h -F 256 $i/chimericPE.sam >$i/"$i"_ChimericPE.sam_F256_filtered.sam &
	
#done
#wait

##Merge the files of chimericPE and Align
#here I switch the order of input files
for i in $(ls -d *)
do
	printf "\nstart merging chimericPE and Align files, time is:\n"
	java -Xmx4g -jar /pbtech_mounts/homesA/asboner/Software/picard-tools-1.85/MergeSamFiles.jar SORT_ORDER=queryname TMP_DIR=/aslab_scratch001/asboner_dat/PeterTest/STAROutput/tmp_dir MAX_RECORDS_IN_RAM=1000000 INPUT=$i/"$i"_ChimericPE.sam_F256_filtered.sam INPUT=$i/"$i"_Aligned.out_F256_filtered.sam  OUTPUT=$i/"$i"_chim_Align_merged.sam &

done
wait

## this is the step for QC all of the sam files
#for i in $(ls -d *)
#do
#	cd $i
#	mkdir "$i"_samstat
#	samstat $(ls *.sam) 1>>$(ls *.sam).log 2>>$(ls *.sam).err.log &
#	cd ..
#done
#wait

## sam2mrf
for i in $(ls -d *)
do
	cd $i
    cat "$i"_chim_Align_merged.sam|sam2mrf|mrfSorter>"$i"_chim_Align_merged.mrfSort.mrf &
#	cat "$i"_chim_Align_merged.sam|sam2mrf>"$i"_chim_Align_merged.mrf &
	cd ..
done
wait

##mrfSorter
#for i in $(ls -d *)
#do
#	cd $i
#	mrfSorter <"$i"_chim_Align_merged.mrf>"$i"_chim_Align_merged.mrfSort.mrf &
#	cd ..
#done
#wait

## geneFusions
##The first command (geneFusions) will create the first list of candidate fusion transcripts:
for i in $(ls -d *)
do
	printf "\nhey\n"
	cd $i 
	geneFusions "$i"_chim_Align_merged.mrfSort 4 <"$i"_chim_Align_merged.mrfSort.mrf>"$i"_chim_Align_merged.mrfSort.1.gfr 2>"$i"_chim_Align_merged.mrfSort.1.gfr.log 
	cd ..
done
wait


## Module II--Filtering 
for i in $(ls -d *)
do 
	cd $i
	gfrMitochondrialFilter<"$i"_chim_Align_merged.mrfSort.1.gfr 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrRepeatMaskerFilter /home/asboner/FusionSeqData/human/hg19/hg19_repeatMasker.interval 5 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrCountPairTypes 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrExpressionConsistencyFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAbnormalInsertSizeFilter 0.01 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrPCRFilter 4 4 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrProximityFilter 1000 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAddInfo 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAnnotationConsistencyFilter ribosomal 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAnnotationConsistencyFilter pseudogenes 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrBlackListFilter /home/asboner/FusionSeqData/human/hg19/blackList.txt 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrLargeScaleHomologyFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrRibosomalFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrSmallScaleHomologyFilter 1>"$i"_chim_Align_merged.mrfSort.gfr 2>>"$i"_chim_Align_merged.mrfSort.gfr.log &
	cd ..
done
wait


## preparing .meta file for scoring candidates
for i  in $(ls -d *)
do 
	cd $i
	MAPPED=$(grep -v "AlignmentBlock" "$i"_chim_Align_merged.mrfSort.mrf | grep -v "#" | wc -l) ; printf "Mapped_reads\t%d\n" $MAPPED>"$i"_chim_Align_merged.mrfSort.meta &
	cd ..
done
wait

##scoring candidates
for i  in $(ls -d *)
do 
	cd $i
	gfrConfidenceValues "$i"_chim_Align_merged.mrfSort<"$i"_chim_Align_merged.mrfSort.gfr>"$i"_chim_Align_merged.mrfSort.confidence.gfr &
	cd ..
done 
wait

##gfrCountPairTypes
for i  in $(ls -d *)
do 
	cd $i
	gfrCountPairTypes<"$i"_chim_Align_merged.mrfSort.gfr>"$i"_chim_Align_merged.mrfSort.countPairType.gfr 2>"$i"_chim_Align_merged.mrfSort.countPairType.gfr.log &
	cd ..
done
wait

##gfr2Images
for i  in $(ls -d *)
do 
	cd $i
	mkdir "$i"_gfr2images
	gfr2images<"$i"_chim_Align_merged.mrfSort.confidence.gfr|gfr2bed 2>>"$i"_chim_Align_merged.mrfSort.confidence.aux.log|gfr2fasta 2>>"$i"_chim_Align_merged.mrfSort.confidence.aux.log|gfr2gff 2>>"$i"_chim_Align_merged.mrfSort.confidence.aux.log &
	cd ..
done 
wait

for i  in $(ls -d *)
do 	
	cd $i
	cp $(ls *.jpg) $(pwd)/"$i"_gfr2images
	cp $(ls *.bed) $(pwd)/"$i"_gfr2images
	cp $(ls *.gff) $(pwd)/"$i"_gfr2images
	cp $(ls *.fasta) $(pwd)/"$i"_gfr2images
	rm $(ls *.jpg)&
	rm $(ls *.bed)&
	rm $(ls *.gff)&
	rm $(ls *.fasta)&
	cd ..
done
wait
##move all samstat files
for i in $(ls -d *)
do
        cd $i
        cp $(ls *.html) $(pwd)/"$i"_samstat  # no & sign is important
        rm $(ls *.html)
        cd ..
done
wait

## zip all fastq files
for i  in $(ls -d *)
do
cd $i
gzip "$(ls *R1*.fastq)" &
gzip "$(ls *R2*.fastq)" &
cd ..
done
wait

































