#!/bin/bash
set -e
set -u

## creates the joblist to combine the GFRs
PROGRAM=$(basename $0)

usage() {
    echo
    echo -e "$PROGRAM:\tUsage:\t$PROGRAM -i input_dir -f 1|2 [-o output_dir] [-m meta_dir] [-l label] [-p \"pattern\"] "
    echo -e "$PROGRAM:\t\t-i input_dir\tthe root folder containing the GFR.1 files (INPUT_DIR/SAMPLE/GFR.1/sample*.1.gfr.gz)"
    echo -e "$PROGRAM:\t\t-f format\the format of the files (1. INPUT_DIR/sample*.1.gfr.gz 2. INPUT_DIR/SAMPLE/GFR.1/sample*.1.gfr.gz)"
    echo -e "$PROGRAM:\t\t-o output directory\t[optional: default=./GFR.1/]"
    echo -e "$PROGRAM:\t\t-o output meta directory\t[optional: default=./META/]"
    echo -e "$PROGRAM:\t\t-l label\t[optional] the label to use for the job file"
    echo -e "$PROGRAM:\t\t-p \"pattern\"\tthe subset of samples to run (without .gz.list) [optional: default='*']"
    echo -e "\n$PROGRAM:\tEx: $PROGRAM -i ELAND_1.8 -p \"sampleID\""
}

log() {
    STATUS=$1
    MESSAGE=$2
    echo -e "$PROGRAM:\t$STATUS\t$MESSAGE"
}

if [[ $# -lt 4  ]] 
then
    log "ERROR" "Not enough parameters"
    usage
    exit -1
fi
PID="$$"
LABEL="$PID"
WORKING_DIR=$(pwd -P)
OUTPUT_DIR="$WORKING_DIR/GFR.1"
META_DIR="$WORKING_DIR/META"
PATTERN="*"
SUFFIX=".1.gfr.gz"

while getopts "i:p:l:o:m:f:" optname
  do
  case "$optname" in
      "i")
	  INPUT_DIR=$OPTARG
	  ;;
      "p")
	  PATTERN=$OPTARG
	  ;;
      "l")
	  LABEL=$OPTARG
	  ;;
      "o")
	  OUTPUT_DIR=$OPTARG
	  ;;
      "m")
	  META_DIR=$OPTARG
	  ;;
      "f")
	  FORMAT=$OPTARG
	  ;;
      "?")
	  log "ERROR" "Unknown option $OPTARG"
	  exit -1
	  ;;
      ":")
	  log "ERROR" "No argument value for option $OPTARG"
	  exit -1
	  ;;
      *)
      # Should not occur
	  log "ERROR" "Unknown error while processing options"
	  exit -1
	  ;;
  esac    
done

log "" "INPUT_DIR has value:\t$INPUT_DIR"
log "" "FORMAT has value:\t$FORMAT"
log "" "OUTPUT_DIR has value:\t$OUTPUT_DIR"
log "" "META_DIR has value:\t$META_DIR"
log "" "PATTERN has value:\t$PATTERN"
log "" "Label is:\t$LABEL"

echo "Should I continue? [y|n]"
read -sn 1 ans 
if [ "$ans" != "y" ]; then
    exit 0
fi
JOBLIST="job_combineGFRs.$LABEL.txt"
if [[ $OUTPUT_DIR == "" ]];then 
    log "ERROR" "OUTPUT_DIR cannot be empty"
    exit -1
fi
if [[ ! -e "$OUTPUT_DIR/" ]]; then
    mkdir -p "$OUTPUT_DIR/"
fi
# if [[ ! -e "$OUTPUT_DIR/TRANSLOCATIONS" ]]; then
#     mkdir -p "$OUTPUT_DIR/TRANSLOCATIONS"
# fi
if [[ ! -e "$META_DIR" ]]; then
    mkdir -p "$META_DIR"
fi
echo -n > $JOBLIST
for l in $WORKING_DIR/$PATTERN.list ### reading list file
do
    SAMPLE=$(basename "$l" ".list")
    echo "***** SAMPLE: $SAMPLE";
    NAME=$(head -n1 $l);#log "INFO" "$NAME"
    NAME=$(basename $NAME); #log "INFO" "$NAME"
    ##SAMPLEID=$(echo $NAME | sed 's%\(.*\)_\([A-Za-z]*\)_\(L00[1-8]\)_R\([12]\)_\([0-9]*\)\.fastq.gz%\1%');#log "INFO" "SAMPLEID: $SAMPLEID";
    
    if [[ $FORMAT -eq "1" ]]; then
	GFR_DIR=$INPUT_DIR
	for s in $(cat $l)
	do
	    NAME=$(basename $s)
	    SAMPLEID=$(echo $NAME | sed 's%\(.*\)\.sorted_genome_alignments.bam.1.gfr.gz%\1%');echo $SAMPLEID
	    SAMPLEID=$(echo $NAME | sed 's%\(.*\)\_01.mrf.gz%\1%');echo $SAMPLEID
	    
	    echo "cd $WORKING_DIR;R CMD BATCH --no-save --no-restore '--args sample=\"$SAMPLEID\" gfrDir=\"$GFR_DIR\" metaDir=\"$META_DIR\" minNum=4' ~/bin/combineGFRs.R $GFR_DIR/combineGFR_$SAMPLEID.Rout;mv -f $GFR_DIR/$SAMPLEID.1.gfr.gz $OUTPUT_DIR/;cp -f $META_DIR/$SAMPLEID.meta $OUTPUT_DIR/" >> $JOBLIST 
	done
    else
	GFR_DIR=$INPUT_DIR/$SAMPLE/GFR.1
	echo "cd $WORKING_DIR;R CMD BATCH --no-save --no-restore '--args sample=\"$SAMPLE\" gfrDir=\"$GFR_DIR\" metaDir=\"$META_DIR\"' ~/bin/combineGFRs.R $GFR_DIR/combineGFR_$SAMPLE.Rout;mv -f $GFR_DIR/$SAMPLE.1.gfr.gz $OUTPUT_DIR/;cp -f MRF/$SAMPLE/$SAMPLE.meta $META_DIR/" >> $JOBLIST 
    fi
done
  
echo
echo
NUMJOBS=$(wc -l $JOBLIST | cut -f1 -d " ")
echo There are $NUMJOBS jobs. Here is a sample:
head -n 5 $JOBLIST
echo
NUMPROC=$(grep -c ^processor /proc/cpuinfo)
if [[ $NUMJOBS -gt $NUMPROC ]];then
    let NUMJOBS=$NUMPROC-2
fi
echo -e "export PPSS_DIR=PPSS_DIR_combineGFR.1; ppss -f $JOBLIST -p $NUMJOBS -c 'bash \$ITEM'"
