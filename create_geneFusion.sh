#!/bin/bash
## creates the joblist to run the fusion pipeline
. /home/asboner/bin/common_functions.sh

usage() {
    echo
    log "USAGE" "$PROGRAM:\t$PROGRAM -i input_dir  -r fusionseqrc [-D] [-p \"pattern\"] [-n minNumReads] [-u] [-l label] [-o output_dir]\n"
    log "USAGE" "$PROGRAM:\t-i input_dir\tthe folder where the MRF file(s) is."
    log "USAGE" "$PROGRAM:\t-r fusionseqrc\tthe .fusionseqrc file that should be used for the analysis"
    log "USAGE" "$PROGRAM:\t-p \"pattern\"\tthe sample(s) to search for fusion transcripts. It can include the directory where the MRF files are."
    log "USAGE" "$PROGRAM:\t-D\t\t[optional]The DEVELOPMENT version is used)"
    log "USAGE" "$PROGRAM:\t-n minNumReads\tthe minimum number of reads to select the candidate fusion."
    log "USAGE" "$PROGRAM:\t-u\t\t[optional]The MRF file(s) is NOT compressed (gzipped)"
    log "USAGE" "$PROGRAM:\t-l label\t[optional] the label to use for the job file [default: fusion.1]"
    log "USAGE" "$PROGRAM:\t-o output_dir\t[optional] the output directory for the 1.gfr files [default: ./GFR.1/]\n"
    log "EXAMPLE" "$PROGRAM:\tEx: $PROGRAM -i MRF-r ~/FusionSeqData/human/hg19/.fusionseqrc  -p \"sample_102*\"  -l sample_102"
    log "INFO" "$PROGRAM:\tNB: the output will be saved into a GFR.1 sub-directory, which includes also LOG and intraOffsets. If they're not present, they'll be created."
}


if [[ $# -lt 4 ]] 
then
    log "ERROR" "Not enough parameters"
    usage
    exit -1
fi

PID="$$";
LABEL="$PID"
SUFFIX=".mrf.gz"
CAT="zcat"
OUTPUT_DIR="GFR.1"
MIN_NUM_READS=4
PATTERN="*"
PREFIX_DEV=""
      
while getopts "Dp:l:z:r:i:o:u:n:" optname
  do
  case "$optname" in
      "i")
	  INPUT_DIR=$OPTARG
	  ;;
      "p")
	  PATTERN=$OPTARG
	  ;;
      "n")
	  MIN_NUM_READS=$OPTARG
	  ;;
      "D")
	  PREFIX_DEV="/home/asboner/Software/fusionseq/bin/"
	  log "INFO" "The DEVELOPMENT version will be used\t$PREFIX_DEV"
	  ;;
      "u")
	  log "" "Plain text MRF file(s) is set"
	  SUFFIX=".mrf"
	  CAT="cat"
	  ;;
      "l")
	  LABEL=$OPTARG
	  ;;
      "o")
	  OUTPUT_DIR=$OPTARG
	  ;;
      "r")
	  FUSIONSEQRC=$OPTARG
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
JOBLIST="job_fusion.1.$LABEL.txt"

WORKING_DIR=$(pwd)
log "INFO" "Working directory is:\t$WORKING_DIR"
log "INFO" "INPUT_DIR has value:\t$INPUT_DIR"
log "INFO" "PATTERN has value:\t$PATTERN"
log "INFO" ".fusionseqrc is:\t$FUSIONSEQRC"
log "INFO" "MIN_NUM_READS has value:\t$MIN_NUM_READS"
log "INFO" "OUTPUT_DIR has value:\t$OUTPUT_DIR"
log "INFO" "Label is:\tfusion.1.$LABEL"

if [[ -s $JOBLIST ]]
then
	echo "Joblist $JOBLIST already exist, continue?"
	read -sn 1 ans
	if [[ "$ans" != 'y' ]]; then
	    exit -1
	fi
fi	
if [[ ! -e "$OUTPUT_DIR/intraOffsets/" ]]; then
    mkdir -p "$OUTPUT_DIR/intraOffsets/"
fi
if [[ ! -e "$OUTPUT_DIR/LOG/" ]]; then
    mkdir -p "$OUTPUT_DIR/LOG/"
fi

echo -n > $JOBLIST


###### AD HOC solution for TCGA: TO BE REMOVED
#for f in $(cat failed2.gfr.list)
#do
#    prefix=$(basename $f .1.gfr.gz)
#    echo "cd $WORKING_DIR; export FUSIONSEQ_CONFPATH=$FUSIONSEQRC;( $CAT $prefix.mrf.gz | geneFusions $prefix $MIN_NUM_READS | gfrClassify | gzip) > $OUTPUT_DIR/$prefix.1.gfr.gz 2> $OUTPUT_DIR/LOG/$prefix.1.log; mv -f $prefix.intraOffsets $OUTPUT_DIR/intraOffsets/" >> "$WORKING_DIR/$JOBLIST"
#done
#echo
#echo
#NUMJOBS=$(wc -l $JOBLIST | cut -f1 -d " ")
#echo There are $NUMJOBS jobs. Here is a sample:
#head -n 5 $JOBLIST
#echo
#NUMPROC=$(grep -c ^processor /proc/cpuinfo)
#if [[ $NUMJOBS -gt $NUMPROC ]];then
#    let NUMJOBS=$NUMPROC-2
#fi
#echo -e "export PPSS_DIR=PPSS_DIR_$JOBLIST;ppss -f $JOBLIST -p $NUMJOBS -c 'bash \$ITEM'"

#exit -1
##### END AD-HOC SOLUTION FOR TCGA 

for f in $INPUT_DIR/$PATTERN$SUFFIX
do
  [[ -f "$f" ]] || continue
  doIT=0
  ## extract base name
  prefix=$(basename $f $SUFFIX)
  log "INFO" " $prefix\t"
  if [ ! -s "$OUTPUT_DIR/$prefix.1.gfr.gz" ]
  then
      doIT=1
  else
      TIMEGFR=$(date -r "$OUTPUT_DIR/$prefix.1.gfr.gz" +%s 2> /dev/null)
      TIMEMRF=$(date -r "$INPUT_DIR/$prefix$SUFFIX" +%s)
      if [[ "$TIMEGFR" < "$TIMEMRF" ]]
	  then
	  echo "*********************************************"
	  echo "GfrTime: $(date -r $OUTPUT_DIR/$prefix.1.gfr.gz +%c 2> /dev/null)"
	  echo "MrfTime: $(date -r $INPUT_DIR/$prefix$SUFFIX  +%c)"
	  echo -e "*********************************************\n"
	  doIT=1
      else
	  doIT=1
	  echo -e "\n$PROGRAM:\t$OUTPUT_DIR/$prefix.1.gfr.gz exists. Would you like to replace it?"
	  read -sn 1 ans
	  if [[ "$ans" != 'y' ]]; then
	      doIT=0
	  fi
      fi
  fi
  if [[ $doIT -eq 1 ]]
  then
      ## create script
      echo "cd $WORKING_DIR; export FUSIONSEQ_CONFPATH=$FUSIONSEQRC;( $CAT $f | $PREFIX_DEV""geneFusions $prefix $MIN_NUM_READS | $PREFIX_DEV""gfrClassify | gzip) > $OUTPUT_DIR/$prefix.1.gfr.gz 2> $OUTPUT_DIR/LOG/$prefix.1.log; mv -f $prefix.intraOffsets* $OUTPUT_DIR/intraOffsets/" >> "$WORKING_DIR/$JOBLIST"
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
echo -e "export PPSS_DIR=PPSS_DIR_$JOBLIST;ppss -f $JOBLIST -p $NUMJOBS -c 'bash \$ITEM'"
##echo "From the head node:"
##echo "sqPBS.py gerstein 1 as898 GFD$LABEL $JOBLIST | qsub -m ae -M andrea.sboner@yale.edu"
	  # if [[ -e  ~/.fusionseqrc ]];then
	  #     echo -e "\n$PROGRAM:\t~/.fusionseqrc exists. Would you like to replace it with:\n\t\t\t$OPTARG"
	  #     read -sn 1 ans
	  #     if [[ "$ans" != 'y' ]]; then
	  # 	  if [[ "$ans" == "N" ]]; then
	  # 	      continue;
	  # 	  fi
	  # 	  exit -1
	  #     fi
	  #     log "" "Copying $OPTARG to ~/.fusionseqrc"
	  #     cp $OPTARG ~/.fusionseqrc
	  #fi
