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
#for i in $(ls -d *)
#do
#	cd $i
#	printf "\n$i Start STAR alignment\n"; echo $(pwd)
#  star  --genomeLoad LoadAndRemove --runThreadN 5 --outFileNamePrefix "$i"_ --genomeDir /pbtech_mounts/fdlab_store003/fdlab/genomes/human/hg19/indexes/star --chimSegmentMin 10 --readFilesCommand zcat --readFilesIn "$(ls *R1*fastq.gz)"  &
#   star  --genomeLoad LoadAndRemove --runThreadN 5 --outFileNamePrefix "$i"_ --genomeDir /pbtech_mounts/fdlab_store003/fdlab/genomes/human/hg19/indexes/star --chimSegmentMin 10 --readFilesCommand zcat --readFilesIn "$(ls *R1*fastq.gz)" "$(ls *R2*fastq.gz)" &
#	cd ..
#done
#wait

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
#	samtools view -S -h -F 256 $i/"$i"_Aligned.out.sam >$i/"$i"_Aligned.out_F256_filtered.sam &
#	samtools view -S -h -F 256 $i/chimericPE.sam >$i/"$i"_ChimericPE.sam_F256_filtered.sam &
#done
#wait

##Merge the files of chimericPE and Align
for i in $(ls -d *)
do
    cd $i
	printf "\nstart merging chimericPE and Align files, time is:\n"
	java -Xmx4g -jar /pbtech_mounts/homesA/asboner/Software/picard-tools-1.85/MergeSamFiles.jar SORT_ORDER=queryname TMP_DIR=/aslab_scratch001/asboner_dat/PeterTest/STAROutput/tmp_dir MAX_RECORDS_IN_RAM=1000000 INPUT="$i"_Aligned.out_F256_filtered.sam INPUT="$i"_ChimericPE.sam_F256_filtered.sam OUTPUT=$"$i"_chim_Align_merged.sam 1>>mergesamFile.log 2>>mergesamFile.err.log &
    cd ..
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

##split the mrf files because genefusions cannot take all reads at once
#for i in $(ls -d *)
#do
#    cd $i
#    mkdir split &
#    MAPPED=$(cat $"$i"_chim_Align_merged.mrfSort.meta | cut -f2);echo $MAPPED & ## this reads the number of mapped reads from the meta file.
#    cat $"$i"_chim_Align_merged.mrfSort.mrf | head -n 28 > split/mrf.header &  ## Assuming that the header has 28 lines
#    let N="$MAPPED/2 + 10000";echo $N & ### this determines how many lines to include in each file. Please note that in this case, there are 28 lines as header, adjust this number accordingly
#    cat $"$i"_chim_Align_merged.mrfSort.mrf |split -d -l $N - split/$"$i"_chim_Align_merged.mrfSort""_ & ## the file will be generated into the split directory
#    cd ..
#done
#wait


#for i in $(ls -d *)
#do
#    printf "\nsplit and cat .mrf files\n"
#    cd $i
#    CURRENT=$(pwd)
#    cd split/
#    printf "\n$(pwd)\n"
#    mv "$i"_chim_Align_merged.mrfSort_00 "$i"_chim_Align_merged.mrfSort""_00.mrf &
#    cat mrf.header "$i"_chim_Align_merged.mrfSort_01 > $"$i"_chim_Align_merged.mrfSort_01.mrf &
#    cat mrf.header "$i"_chim_Align_merged.mrfSort_02 > $"$i"_chim_Align_merged.mrfSort_02.mrf &
#    cat mrf.header "$i"_chim_Align_merged.mrfSort_03>$"$i"_chim_Align_merged.mrfSort_03.mrf
#    cat mrf.header "$i"_chim_Align_merged.mrfSort_04>$"$i"_chim_Align_merged.mrfSort_04.mrf
#    cat mrf.header "$i"_chim_Align_merged.mrfSort_05>$"$i"_chim_Align_merged.mrfSort_05.mrf
#    rm $"$i"_chim_Align_merged.mrfSort_01 &
#    rm $"$i"_chim_Align_merged.mrfSort_02 &
#    rm $"$i"_chim_Align_merged.mrfSort_03
#    rm $"$i"_chim_Align_merged.mrfSort_04
#    rm $"$i"_chim_Align_merged.mrfSort_05

#    cd ..
#    cd ..
#done
#wait

###################
#need to creat a .meta file for each of split-mrf files
#the combineGfr also merges the meta files, but it does so after it has combined the GFR files. So, even if you get an error, this will not affect the combined GFR.
###################



## geneFusions
##The first command (geneFusions) will create the first list of candidate fusion transcripts:
#for i in $(ls -d *)
#do
#	printf "\nhey~geneFusions start lo\n"
#	cd $i
#	geneFusions "$i"_chim_Align_merged.mrfSort_00 4 <split/"$i"_chim_Align_merged.mrfSort_00.mrf>split/"$i"_chim_Align_merged.mrfSort_00.1.gfr 2>split/"$i"_chim_Align_merged.mrfSort_00.1.gfr.log &
#	geneFusions "$i"_chim_Align_merged.mrfSort_01 4 <split/"$i"_chim_Align_merged.mrfSort_01.mrf>split/"$i"_chim_Align_merged.mrfSort_01.1.gfr 2>split/"$i"_chim_Align_merged.mrfSort_01.1.gfr.log &
#	geneFusions "$i"_chim_Align_merged.mrfSort_02 4 <split/"$i"_chim_Align_merged.mrfSort_02.mrf>split/"$i"_chim_Align_merged.mrfSort_02.1.gfr 2>split/"$i"_chim_Align_merged.mrfSort_02.1.gfr.log &
#	cd ..
#done
#wait

#for i in $(ls -d *)
#do
#    printf "\nStart zipping gfr files\n"
#    cd $i/split
#    gzip $(ls *gfr)
#    cd ..
#    cd ..
#    done
#wait



#for i in $(ls -d *)
#do
#    cd $i
#    CURRENT=$(pwd); echo $CURRENT
#    cd split
#    rm $(ls *mrf) &
#    gzip $(ls *gfr) &
#    cp $(ls *log*) $CURRENT
#    rm $(ls *log*)
#cd ..
#cd ..
#done
#wait

## runging R, but have to run it invidually so far
#for i in $(ls -d *)
#do
#    cd $i
#    CURRENT=$(pwd); echo $CURRENT
#    cd split
#    rm $(ls *mrf) &
#    echo "$i"_chim_Align_merged.mrfSort
#/aslab_scratch001/asboner_dat/software/Rbuild/usr/bin/R CMD BATCH --no-save --no-restore '--args sample="ME241_chim_Align_merged.mrfSort" gfrDir="/aslab_scratch001/asboner_dat/PeterTest/0428_MEsample/ME241/split" metaDir="/aslab_scratch001/asboner_dat/PeterTest/0428_MEsample/ME283" minNum=4' /home/ys486/bin/combineGFRs.R /aslab_scratch001/asboner_dat/PeterTest/G1_III/G1_III/split/combineGFR_ME241_chim_Align_merged.mrfSort_.Rout
#    /aslab_scratch001/asboner_dat/software/Rbuild/usr/bin/R CMD BATCH --no-save --no-restore '--args sample="'$i'_chim_Align_merged.mrfSort" gfrDir="$(pwd)" metaDir="CURRENT" minNum=4' /home/ys486/bin/combineGFRs.R $(pwd)/combineGFR_"$i"_chim_Align_merged.mrfSort_.Rout &
#    cd ..
#    cd ..
#done
#wait




## Module II--Filtering
#for i in $(ls -d *)
#do
#	cd $i
#	zcat "$i"_chim_Align_merged.mrfSort.1.gfr.gz | gfrMitochondrialFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrRepeatMaskerFilter /home/asboner/FusionSeqData/human/hg19/hg19_repeatMasker.interval 5 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrCountPairTypes 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrExpressionConsistencyFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAbnormalInsertSizeFilter 0.01 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrPCRFilter 4 4 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrProximityFilter 1000 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAddInfo 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAnnotationConsistencyFilter ribosomal 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAnnotationConsistencyFilter pseudogenes 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrBlackListFilter /home/asboner/FusionSeqData/human/hg19/blackList.txt 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrLargeScaleHomologyFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrRibosomalFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrSmallScaleHomologyFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log |  gfrRandomPairingFilter 1>"$i"_chim_Align_merged.mrfSort.gfr 2>>"$i"_chim_Align_merged.mrfSort.gfr.log &
#	cd ..
#done
#wait




##scoring candidates
#for i  in $(ls -d *)
#do
#	cd $i
#	gfrConfidenceValues "$i"_chim_Align_merged.mrfSort<"$i"_chim_Align_merged.mrfSort.gfr>"$i"_chim_Align_merged.mrfSort.confidence.gfr &
#	cd ..
#done
#wait

##gfrCountPairTypes
#for i  in $(ls -d *)
#do
#	cd $i
#	gfrCountPairTypes<"$i"_chim_Align_merged.mrfSort.gfr>"$i"_chim_Align_merged.mrfSort.countPairType.gfr 2>"$i"_chim_Align_merged.mrfSort.countPairType.gfr.log &
#	cd ..
#done
#wait

##gfr2Images
#for i  in $(ls -d *)
#do
#	cd $i
#	gfr2images<"$i"_chim_Align_merged.mrfSort.confidence.gfr|gfr2bed 2>>"$i"_chim_Align_merged.mrfSort.confidence.aux.log|gfr2fasta 2>>"$i"_chim_Align_merged.mrfSort.confidence.aux.log|gfr2gff 2>>"$i"_chim_Align_merged.mrfSort.confidence.aux.log &
#	cd ..
#done
#wait

##copy and remove images
#for i  in $(ls -d *)
#do
#	cd $i
#	cp $(ls *.jpg) $(pwd)/"$i"_gfr2images
#	cp $(ls *.bed) $(pwd)/"$i"_gfr2images
#	cp $(ls *.gff) $(pwd)/"$i"_gfr2images
#	cp $(ls *.fasta) $(pwd)/"$i"_gfr2images
#	rm $(ls *.jpg)&
#	rm $(ls *.bed)&
#	rm $(ls *.gff)&
#	rm $(ls *.fasta)&
#	cd ..
#done
#wait

##move all samstat files
#for i in $(ls -d *)
#do
#        cd $i
#        cp $(ls *.html) $(pwd)/"$i"_samstat  # no & sign is important
#        rm $(ls *.html)
#        cd ..
#done
#wait

## zip all fastq files
#for i  in $(ls -d *)
#do
#cd $i
#gzip "$(ls *R1*.fastq)" &
#gzip "$(ls *R2*.fastq)" &
#cd ..
#done
#wait

































