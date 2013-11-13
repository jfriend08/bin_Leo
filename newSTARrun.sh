#!/bin/bash

##STAR alignment
##this time without outSAMunmapped specified
#for i in $(ls -d *)
#do
#	cd $i
#	printf "\n$i Start STAR alignment\n"; echo $(pwd)
#   star  --genomeLoad LoadAndRemove --runThreadN 5 --outFileNamePrefix "$i"_ --genomeDir /pbtech_mounts/fdlab_store003/fdlab/genomes/human/hg19/indexes/star --chimSegmentMin 10 --readFilesCommand zcat --readFilesIn "$(ls *R1*fastq.gz)" "$(ls *R2*fastq.gz)" &
#	cd ..
#done
#wait

#for i  in $(ls -d *)
#do
#    cd $i
#    printf "\nMove zip\n"
#    mv "$(ls *R1*fastq.gz)" /aslab_scratch001/asboner_dat/PeterTest/DataSet/Run5/$i &
#    mv "$(ls *R2*fastq.gz)" /aslab_scratch001/asboner_dat/PeterTest/DataSet/Run5/$i &
#    cd ..
#done
#wait

#for i in $(ls -d *)
#do
#    grep p $i/"$i"_Chimeric.out.junction | cut -f 10 >"$i"/"$i"_ID_list.txt &
#done
#wait

#for i in $(ls -d *)
#do
#	cd $i
#    Split_FJR.2.pl "$i"_Chimeric.out.sam "$i"_ID_list.txt
#	cd ..
#done
#wait

#for i in $(ls -d *)
#do
#	samtools view -S -h -F 256 -@8 $i/"$i"_Aligned.out.sam >$i/"$i"_Aligned.out_F256_filtered.sam &
#	samtools view -S -h -F 256 -@8 $i/chimericPE.sam >$i/"$i"_ChimericPE.sam_F256_filtered.sam &
#done
#wait




##Merge the files of chimericPE and Align
#for i in $(ls -d *)
#do
#    cd $i
#	printf "\nstart merging chimericPE and Align files, time is:\n"
#	java -Xmx4g -jar /pbtech_mounts/homesA/asboner/Software/picard-tools-1.85/MergeSamFiles.jar SORT_ORDER=queryname TMP_DIR=/aslab_scratch001/asboner_dat/PeterTest/STAROutput/tmp_dir MAX_RECORDS_IN_RAM=1000000 INPUT="$i"_Aligned.out_F256_filtered.sam INPUT="$i"_ChimericPE.sam_F256_filtered.sam OUTPUT=$"$i"_chim_Align_merged.sam 1>>mergesamFile.log 2>>mergesamFile.err.log &
#    cd ..
#done
#wait

## sam2mrf
#for i in $(ls -d *)
#do
#	cd $i
#    printf "\nsam2mrf\n"
#    cat "$i"_chim_Align_merged.sam|sam2mrf|mrfSorter>"$i"_chim_Align_merged.mrfSort.mrf &
#	cd ..
#done
#wait

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

## geneFusions
##The first command (geneFusions) will create the first list of candidate fusion transcripts:
#for i in $(ls -d *)
#do
#    printf "\nhey~geneFusions start lo\n"
#    cd $i
#    geneFusions "$i"_chim_Align_merged.mrfSort 4 < "$i"_chim_Align_merged.mrfSort.mrf> "$i"_chim_Align_merged.mrfSort.1.gfr 2>"$i"_chim_Align_merged.mrfSort.1.gfr.log &
#    cd ..
#done
#wait

#for i in $(ls -d *)
#do
#    printf "\nStart zipping gfr files\n"
#    cd $i
#    gzip $(ls *gfr) &
#    gzip $(ls *mrf) &
#    cd ..
#done
#wait


## Module II--Filtering
for i in $(ls -d *)
do
    cd $i
   zcat "$i"_chim_Align_merged.mrfSort.1.gfr.gz | gfrMitochondrialFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrRepeatMaskerFilter 5 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrCountPairTypes 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrExpressionConsistencyFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAbnormalInsertSizeFilter 0.01 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrPCRFilter 4 4 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrProximityFilter 1000 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAddInfo 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAnnotationConsistencyFilter ribosomal 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAnnotationConsistencyFilter pseudogenes 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrBlackListFilter /home/asboner/FusionSeqData/human/hg19/blackList.txt 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrLargeScaleHomologyFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrRibosomalFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrSmallScaleHomologyFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log |  gfrRandomPairingFilter 1>"$i"_chim_Align_merged.mrfSort.gfr 2>>"$i"_chim_Align_merged.mrfSort.gfr.log &

#zcat "$i"_chim_Align_merged.mrfSort.1.gfr.gz | gfrMitochondrialFilter 2>>"$i"_chim_Align_merged.mrfSort_old.gfr.log | gfrRepeatMaskerFilter /home/asboner/FusionSeqData/human/hg19/hg19_repeatMasker.interval 5 2>>"$i"_chim_Align_merged.mrfSort_old.gfr.log | gfrCountPairTypes 2>>"$i"_chim_Align_merged.mrfSort_old.gfr.log | gfrExpressionConsistencyFilter 2>>"$i"_chim_Align_merged.mrfSort_old.gfr.log | gfrAbnormalInsertSizeFilter 0.01 2>>"$i"_chim_Align_merged.mrfSort_old.gfr.log | gfrPCRFilter 4 4 2>>"$i"_chim_Align_merged.mrfSort_old.gfr.log | gfrProximityFilter 1000 2>>"$i"_chim_Align_merged.mrfSort_old.gfr.log | gfrAddInfo 2>>"$i"_chim_Align_merged.mrfSort_old.gfr.log | gfrAnnotationConsistencyFilter ribosomal 2>>"$i"_chim_Align_merged.mrfSort_old.gfr.log | gfrAnnotationConsistencyFilter pseudogenes 2>>"$i"_chim_Align_merged.mrfSort_old.gfr.log | gfrBlackListFilter /home/asboner/FusionSeqData/human/hg19/blackList.txt 2>>"$i"_chim_Align_merged.mrfSort_old.gfr.log | gfrLargeScaleHomologyFilter 2>>"$i"_chim_Align_merged.mrfSort_old.gfr.log | gfrRibosomalFilter 2>>"$i"_chim_Align_merged.mrfSort_old.gfr.log | gfrSmallScaleHomologyFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log |  gfrRandomPairingFilter 1>"$i"_chim_Align_merged.mrfSort_old.gfr 2>>"$i"_chim_Align_merged.mrfSort_old.gfr.log &
    cd ..
    done
    wait
#scoring candidates
for i  in $(ls -d *)
do
	cd $i
	gfrConfidenceValues "$i"_chim_Align_merged.mrfSort<"$i"_chim_Align_merged.mrfSort.gfr>"$i"_chim_Align_merged.mrfSort.confidence.gfr &
#    gfrConfidenceValues "$i"_chim_Align_merged.mrfSort_old<"$i"_chim_Align_merged.mrfSort_old.gfr>"$i"_chim_Align_merged.mrfSort_old.confidence.gfr &

	cd ..
done
wait

##gfrCountPairTypes
for i  in $(ls -d *)
do
	cd $i
	gfrCountPairTypes<"$i"_chim_Align_merged.mrfSort.gfr>"$i"_chim_Align_merged.mrfSort.countPairType.gfr 2>"$i"_chim_Align_merged.mrfSort.countPairType.gfr.log &
#	gfrCountPairTypes<"$i"_chim_Align_merged.mrfSort_old.gfr>"$i"_chim_Align_merged.mrfSort_old.countPairType.gfr 2>"$i"_chim_Align_merged.mrfSort_old.countPairType.gfr.log &
	cd ..
done
wait

##gfrClassify
for i  in $(ls -d *)
do
    cd $i
#    cat "$i"_chim_Align_merged.mrfSort_old.confidence.gfr|gfrClassify > "$i"_chim_Align_merged.mrfSort_old.confidence.classify.gfr &
    cat "$i"_chim_Align_merged.mrfSort.confidence.gfr|gfrClassify > "$i"_chim_Align_merged.mrfSort.confidence.classify.gfr &
    cd ..
done
wait

##find FJR support
for i  in $(ls -d *)
do
    cd $i
    CURRENT=$(pwd); echo $CURRENT
    printf "start find FJR\n"
#    findFJR.pl $CURRENT FJR.sam "$i"_chim_Align_merged.mrfSort_old.confidence.classify.gfr > "$i"_chim_Align_merged.mrfSort_old.confidence.classify.findFJR.gfr &
    findFJR.pl $CURRENT/"$i"_SAMfile FJR.sam "$i"_chim_Align_merged.mrfSort.confidence.classify.gfr > "$i"_chim_Align_merged.mrfSort.confidence.classify.findFJR.gfr &
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


##copy and remove images
for i  in $(ls -d *)
do
    cd $i
    mkdir "$i"_gfr2images
    mkdir "$i"_SAMfile
    mkdir "$i"_MRFfile
    mkdir "$i"_GFRfile
    mv $(ls *.jpg) ./"$i"_gfr2images
    mv $(ls *.bed) ./"$i"_gfr2images
    mv $(ls *.gff) ./"$i"_gfr2images
    mv $(ls *sam*) ./"$i"_SAMfile
    mv $(ls *mrfSort*gfr*) ./"$i"_GFRfile
    mv $(ls *mrfSort*mrf*) ./"$i"_MRFfile
    cd ..
done
wait
