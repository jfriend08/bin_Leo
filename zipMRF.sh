#!/bin/bash
for i in $(ls -d *)
do
    cd $i
    CURRENT=$(pwd); echo $CURRENT
    cd "$i"_MRFfile
    gzip $(ls *.mrf) &
    cd ..
    cd ..
done
wait
