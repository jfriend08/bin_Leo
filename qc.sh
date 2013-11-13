#!/bin/bash

## this is the step for QC all of the sam files
for i in $(ls -d *)
do
	cd $i
	mkdir "$i"_samstat
	samstat $(ls "$i"*Aligned.out.sam)
    samstat $(ls "$i"*Chimeric.out.sam)
	cd ..
done
wait