#!/bin/bash

#make gene expression file
for i in $(ls -d *)
    do
        cd $i/"$i"_MRFfile
        printf "\n"$i"\n"
        zcat $(ls *mrf.gz)|mrfQuantifier ~/hg19/ensembl_EwingMerged_GRCh37.73.interval multipleOverlap >./"$i"_ensembl_merged_geneExpr.txt &
        cd ..
        cd ..
done
wait
