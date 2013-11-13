#!/bin/bash
#set -e
set -u

## creates the joblist to run the fusion pipeline
PROGRAM=$(basename $0)

usage() {
    echo
    echo -e "$PROGRAM:\tUsage:\t$PROGRAM -i inputDir -f format<1|2> [-o output_dir] [-p \"pattern\"] [-m minDepth]"
    echo -e "$PROGRAM:\t\t-i inputDir\tthe input directory. Assumption: each sample has its own folder, this is the root folder"
    echo -e "$PROGRAM:\t\t-f format of the FASTQ file:\n\t\t\t\t\t1 = INPUT_DIR/[SAMPLE]/PATTERN.fastq\n\t\t\t\t\t2 = INPUT_DIR/[SAMPLE]/PATTERN*_[0-9][0-9][0-9].fastq "
    echo -e "$PROGRAM:\t\t-p \"pattern\"\tthe subset of samples to run [optional]"
    echo -e "\n$PROGRAM:\tEx: $PROGRAM -i ~/genomes/human/hg19/index/eland/genome_sj75 -l some_samples"
    echo -e "$PROGRAM:\tNB: the output will be saved into a current directory."
}

log() {
    STATUS=$1
    MESSAGE=$2
    echo -e "[ $(date '+%b %d %R:%S') ] $PROGRAM:\t$STATUS\t$MESSAGE"
}

if [[ $# -lt 2 ]] 
then
    log "ERROR" "Not enough parameters"
    usage
    exit -1
fi

PID="$$"
LABEL="$PID"
WORKING_DIR=$(pwd -P)
OUTPUT_DIR="$WORKING_DIR"
PATTERN="*"
BAM=""
MIN_DEPTH=1
while getopts "f:p:i:o:m:" optname
  do
  case "$optname" in
       "f")
	  FORMAT=$OPTARG
	  ;;
     "p")
	  PATTERN=$OPTARG
	  ;;
      "o")
	  OUTPUT_DIR=$OPTARG
	  ;;
      "m")
	  MIN_DEPTH=$OPTARG
	  ;;
      "i")
	  INPUT_DIR=$(readlink -f $OPTARG)
	  if [[ ! -e $INPUT_DIR ]];then
	      log "ERROR" "$INPUT_DIR does not exists"
	      exit -1;
	  fi
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
log "" "OUTPUT_DIR has value:\t$OUTPUT_DIR"
log "" "INPUT is:\t$(readlink -f $INPUT_DIR)"
log "" "FORMAT is:\t$FORMAT"
log "" "MIN_DEPTH is:\t$MIN_DEPTH"
log "" "PATTERN has value:\t$PATTERN"



echo "Should I continue? [y|n]"
read -sn 1 ans 
if [ "$ans" != "y" ]; then
    exit 0
fi
for l in $(find -L $INPUT_DIR -maxdepth 1 -mindepth $MIN_DEPTH -type d -name "$PATTERN") 
do
    SAMPLE=$(basename "$l");log "INFO" "$SAMPLE"
    if [[ -e $SAMPLE.list ]];then
	rm $SAMPLE.list
    fi
done
for l in $(find -L $INPUT_DIR -maxdepth 1  -mindepth $MIN_DEPTH -type d -name "$PATTERN") 
do
    SAMPLE=$(basename "$l");#log "INFO" "$SAMPLE"
    if [[ $FORMAT == 1 ]];then
	if [[ $MIN_DEPTH == 1 ]];then
	    /bin/ls $INPUT_DIR/$SAMPLE/$PATTERN*.fastq[.][g][z] >> $SAMPLE.list 2> /dev/null || continue
	else
	    /bin/ls $INPUT_DIR/$PATTERN*.fastq[.][g][z] >> $SAMPLE.list 2> /dev/null || continue
	fi
    else
	if [[ $MIN_DEPTH == 1 ]];then
	    /bin/ls $INPUT_DIR/$SAMPLE/$PATTERN*_[0-9][0-9][0-9].fastq[.][g][z] >> $SAMPLE.list 2> /dev/null 
	else
	    /bin/ls $INPUT_DIR/$PATTERN*_[0-9][0-9][0-9].fastq[.][g][z] >> $SAMPLE.list 2> /dev/null || continue
	fi
    fi
    if [[ ! -s $SAMPLE.list ]];then 
	rm $SAMPLE.list
    fi
done
  



