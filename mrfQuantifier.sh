#!/bin/bash

#make gene expression file
for i in $(ls -d *)
do
    cd $i/"$i"_MRFfile
    printf "\n"$i"\n"
    zcat $(ls "$i"*mrfSort.mrf.gz)|mrfQuantifier /home/asboner/annotations/human/hg19/ucsc/2013.09.10/knownGeneAnnotationTranscriptCompositeModel_nh_2013.09.10.interval multipleOverlap >./"$i"_geneExpr.txt &
#    zcat $(ls "$i"*mrfSort.mrf.gz)|mrfQuantifier /home/asboner/annotations/human/hg19/ucsc/knownGeneAnnotationExonCompositeModel.interval multipleOverlap >./"$i"_exonGeneExpr.txt &
    cd ..
    cd ..
done
wait


#quantifier add info
for i in $(ls -d *)
do
    cd $i/"$i"_MRFfile
    printf "\n"$i"\n"
    cat "$i"_geneExpr.txt|quantifierAddInfo>"$i"_geneExpr_Info.txt &
#    cat "$i"_exonGeneExpr.txt|quantifierAddInfo>"$i"_exonGeneExpr_Info.txt &
    cd ..
    cd ..
done 
wait