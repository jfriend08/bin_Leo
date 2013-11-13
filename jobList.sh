#!/bin/bash
echo -n > $JOBLIST
if [[ $FORMAT -eq 3 ]];then
SAMPLEID=""
for l in $WORKING_DIR/$PATTERN.list
do
FIRST_READ=""
for f in $(cat $l | grep "_1.fastq")
do
FASTQ_DIR=$(dirname $f);#log "FASTQ_DIR:" "$FASTQ_DIR";
NAME=$(basename $f );#log "NAME:"  "$NAME";
SAMPLEID=$(echo $NAME | sed 's%\(.*\)_R*\([12]\)_*[0-9]*.fastq.gz%\1%');log "SAMPLEID" "$SAMPLEID"
if [[ $FIRST_READ == "" ]];then
FIRST_READ=$f
else
FIRST_READ="$FIRST_READ,$f"
fi
done
if [[ -s $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.sam ]];then
continue;
fi
if [[ -s $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.bam ]];then
continue;
fi
SECOND_READ=""
for f in $(cat $l | grep "_2.fastq")
do
if [[ $SECOND_READ == "" ]];then
SECOND_READ=$f
else
SECOND_READ="$SECOND_READ,$f"
fi
done
if [[ $FIRST_READ == "" ]];then
continue
else
if [[ ! -e "$OUTPUT_DIR/$(basename $l .list)" ]]; then
mkdir -p  "$OUTPUT_DIR/$(basename $l .list)"
fi
echo "star --genomeDir $REFERENCE --genomeLoad LoadAndKeep --runThreadN 2 --readFilesCommand $CAT --readFilesIn $FIRST_READ $SECOND_READ --outFileNamePrefix $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_ --chimSegmentMin $CHIMERIC_SIZE --outSAMstrandField intronMotif --outSAMunmapped None --outReadsUnmapped fastx;samtools view -Shb $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.sam > $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.bam 2> $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.bam.log;if [[ \$(samtools view -Sc $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.sam) != \$(samtools view -c $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.bam) ]];then printf \"$OUTPUT_DIR/$(basename $l .list)/$SAMPLEID\\tNOT OK\" > $SAMPLEID.check; else printf \"$OUTPUT_DIR/$(basename $l .list)/$SAMPLEID\\tOK\\nRemoving $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.sam\" > $SAMPLEID.check; rm $f; fi;" >> $JOBLIST
fi
done