#!/bin/bash
for i in $(ls -d *)
do
    cd $i
    CURRENT=$(pwd); echo $CURRENT
#    cd "$i"_MRFfile
    cp $(ls *geneExpr_Info.txt) /aslab_scratch001/asboner_dat/PeterTest/geneExpr/new_ucsc &
    cd ..
#    cd ..
done
wait
