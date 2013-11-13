#!/bin/bash
## Module II--Filtering
#for i in $(ls -d *_chim_Align_merged.mrfSort.NovalTAR.1.gfr)
#do
    printf "$i"
#	cat "$i" | gfrMitochondrialFilter 2>>"$i".log | gfrRepeatMaskerFilter 5 2>>"$i".log | gfrCountPairTypes 2>>"$i".log | gfrExpressionConsistencyFilter 2>>"$i".log | gfrAbnormalInsertSizeFilter 0.01 2>>"$i".log | gfrPCRFilter 4 4 2>>"$i".log | gfrProximityFilter 1000 2>>"$i".log | gfrAddInfo 2>>"$i".log | gfrAnnotationConsistencyFilter ribosomal 2>>"$i".log | gfrAnnotationConsistencyFilter pseudogenes 2>>"$i".log | gfrBlackListFilter /home/asboner/FusionSeqData/human/hg19/blackList.txt 2>>"$i".log | gfrLargeScaleHomologyFilter 2>>"$i".log | gfrRibosomalFilter 2>>"$i".log | gfrSmallScaleHomologyFilter 2>>"$i".log |  gfrRandomPairingFilter 1>"$i".gfr 2>>"$i".log &

#cat "$i" | gfrMitochondrialFilter 2>>"$i".log | gfrRepeatMaskerFilter /home/asboner/FusionSeqData/human/hg19/hg19_repeatMasker.interval 5 2>>"$i".log | gfrCountPairTypes 2>>"$i".log | gfrExpressionConsistencyFilter 2>>"$i".log | gfrAbnormalInsertSizeFilter 0.01 2>>"$i".log | gfrPCRFilter 4 4 2>>"$i".log | gfrProximityFilter 1000 2>>"$i".log | gfrAddInfo 2>>"$i".log | gfrAnnotationConsistencyFilter ribosomal 2>>"$i".log | gfrAnnotationConsistencyFilter pseudogenes 2>>"$i".log | gfrBlackListFilter /home/asboner/FusionSeqData/human/hg19/blackList.txt 2>>"$i".log | gfrLargeScaleHomologyFilter 2>>"$i".log | gfrRibosomalFilter 2>>"$i".log | gfrSmallScaleHomologyFilter 2>>"$i".log |  gfrRandomPairingFilter 1>"$i".gfr 2>>"$i".log &
#done
#wait


##gfrClassify
for i  in $(ls -d *NovalTAR.gfr)
do
cat "$i"|gfrClassify > "$i"_classify.gfr &

done
wait