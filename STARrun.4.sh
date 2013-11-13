#!/bin/bash
for i in $(ls -d *)
do
    cd $i
    CURRENT=$(pwd)
    cd split
    mv "$i"_chim_Align_merged.mrfSort.1.gfr.gz $CURRENT
    cd ..
    cd ..
done
wait

## Module II--Filtering
for i in $(ls -d *)
    do
    cd $i
    zcat "$i"_chim_Align_merged.mrfSort.1.gfr.gz | gfrMitochondrialFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrRepeatMaskerFilter /home/asboner/FusionSeqData/human/hg19/hg19_repeatMasker.interval 5 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrCountPairTypes 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrExpressionConsistencyFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAbnormalInsertSizeFilter 0.01 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrPCRFilter 4 4 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrProximityFilter 1000 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAddInfo 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAnnotationConsistencyFilter ribosomal 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrAnnotationConsistencyFilter pseudogenes 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrBlackListFilter /home/asboner/FusionSeqData/human/hg19/blackList.txt 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrLargeScaleHomologyFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrRibosomalFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log | gfrSmallScaleHomologyFilter 2>>"$i"_chim_Align_merged.mrfSort.gfr.log |  gfrRandomPairingFilter 1>"$i"_chim_Align_merged.mrfSort.gfr 2>>"$i"_chim_Align_merged.mrfSort.gfr.log &
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

##gfrClassify
for i  in $(ls -d *)
do
    cd $i
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
    findFJR.pl $CURRENT FJR.sam "$i"_chim_Align_merged.mrfSort.confidence.classify.gfr > "$i"_chim_Align_merged.mrfSort.confidence.classify.findFJR.gfr &
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



## zip all fastq files
for i  in $(ls -d *)
do
    cd $i
    gzip "$(ls *R1*.fastq)" &
    gzip "$(ls *R2*.fastq)" &
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
    mv $(ls *.jpg) $(pwd)/"$i"_gfr2images
    mv $(ls *.bed) $(pwd)/"$i"_gfr2images
    mv $(ls *.gff) $(pwd)/"$i"_gfr2images
    mv $(ls *.fasta) $(pwd)/"$i"_gfr2images
    mv $(ls *sam) $(pwd)/"$i"_SAMfile
    mv $(ls *mrf) $(pwd)/"$i"_MRFfile
    mv $(ls *gfr) $(pwd)/"$i"_GFRfile
    cd ..
done
wait
