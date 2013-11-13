#!/bin/bash 
. /home/asboner/bin/common_functions.sh

usage() {
    echo -e "Usage $PROGRAM -f filter.list -i GFR.1_folder  -m META_folder  -r fusionseqrc [-u] [-p \"prefix\"] [-D] [-o output.folder] [-l label]"
    echo -e "$PROGRAM:\t-f\ttext file with the list of filters to use, one per line."
    echo -e "$PROGRAM:\t-i\tthe folder containing the GFR.1 file(s)" 
    echo -e "$PROGRAM:\t-m\tthe folder containing the meta file(s)" 
    echo -e "$PROGRAM:\t-o\tthe output folder containing the GFR file(s) [optional(default=GFR/)]" 
    echo -e "$PROGRAM:\t-r\tthe .fusionseqrc that has to be used for the analysis"
    echo -e "$PROGRAM:\t-p\tthe prefix to subselect the samples.NB: prefix should be quoted [optional (default:\"*\")]" 
    echo -e "$PROGRAM:\t-D\tif set, then development version is used [optional (default: not set)]"
    echo -e "$PROGRAM:\t-u\tif set, then the GFR.1 files are not compressed [optional (default: not set)]"
    echo -e "$PROGRAM:\t-l\tthe label to use for the job_list file name [optional (default:fusion.filters)]"
    echo -e "\n$PROGRAM: Example:\n\t\t\t$PROGRAM -f filter.list -d GFR.1 -p \"*\" -r hg18/.fusionseqrc\n"
}


if [[ $# -lt 8 ]] 
then
	log "ERROR" "Not enough parameters"
	usage
	exit -1
fi
GFRinitial="GFR.1"
GFR1SUFFIX=".1.gfr.gz"
ZCAT="zcat"
LABEL="$$"
OUTPUT_DIR="GFR"
PATTERN="*"
PREFIX_DEV=""
while getopts "Dp:f:r:i:l:m:o:u" optname
  do
  case "$optname" in
      "p")
	  PATTERN=$OPTARG
	  ;;
      "f")
	  FILTER_LIST=$OPTARG
	  ;;
      "o")
	  OUTPUT_DIR=$OPTARG
	  ;;
      "i")
	  GFRinitial=$OPTARG
	  ;;
      "D")
	  PREFIX_DEV="/home/asboner/Software/fusionseq/bin/"
	  log "INFO" "The DEVELOPMENT version will be used\t$PREFIX_DEV"
	  ;;
      "m")
	  META=$OPTARG	  
	  if [[ ! -e $META ]];then
	      log "ERROR" "Cannot find META directory:\t$META"
	      exit -3
	  fi
	  ;;
      "D")
	  PREFIX_DEV="~/home/asboner/Software/fusionseq/bin/"
	  log "INFO" "The DEVELOPMENT version will be used\t$PREFIX_DEV"
	  ;;
      "r")
	  log "" ".fusionseqrc is:\t$OPTARG"
	  FUSIONSEQRC=$OPTARG
	  if [[ ! -e $FUSIONSEQRC ]];then
	      log "ERROR" "Cannot find FUSIONSEQRC file:\t$FUSIONSEQRC"
	      exit -3
	  fi
	  # if [[ -e  ~/.fusionseqrc ]];then
	  #     log "QUESTION" "~/.fusionseqrc exists. Would you like to replace it with:\t$OPTARG"
	  #     read -sn 1 ans
	  #     if [[ "$ans" != 'y' ]]; then
	  # 	  if  [[ "$ans" == 'N' ]];then 
	  # 		continue
	  # 	  fi
	  # 	  exit -1
	  #     fi
	  #     log "" "\tCopying $OPTARG to ~/.fusionseqrc"
	  #     cp $OPTARG ~/.fusionseqrc
	  # fi
	  ;;
      "u")
	  log "" "Plain text GFR.1 file(s) is set"
	  GFR1SUFFIX=".1.gfr"
	  ZCAT="cat"
	  ;;
      "l") 
	  LABEL="$OPTARG"
	  ;;
      "?")
	  log "ERROR" "Unknown option $OPTARG"
	  ;;
      ":")
	  log "ERROR" "No argument value for option $OPTARG"
	  ;;
      *)
      # Should not occur
	  log "ERROR" "Unknown error while processing options"
	  ;;
  esac    
done
if [[ ! -e $FUSIONSEQRC ]]; then
    log "ERROR" "Cannot find FUSIONSEQRC file:\t$FUSIONSEQRC"
     exit -3
fi

log "" "GFR Initial is:\t$GFRinitial"
log "" "FILTERLIST is:\t$FILTER_LIST"
log "" "FUSIONSEQRC has value:\t$FUSIONSEQRC"
log "" "PATTERN has value:\t$PATTERN"
log "" "META folder is:\t$META"
log "" "LABEL is:\t$LABEL"
log "" "OUTPUT_DIR is:\t$OUTPUT_DIR"

if [[ ! -e "$FILTER_LIST" ]];then
    log "ERROR" "The list of filters does not exist:\t$FILTER_LIST"
    usage
    echo
    exit -2
fi

WORKING_DIR=$(pwd)
if [[ ! -e $OUTPUT_DIR ]];then
    mkdir $OUTPUT_DIR
fi
echo

JOBLIST="job_fusion_filter.$LABEL.txt"
echo -n "" > $JOBLIST
for f in $GFRinitial/$PATTERN$GFR1SUFFIX ##$files
do
  ## extract base name
  prefix=$(basename $f $GFR1SUFFIX)
  echo -n "$prefix | "
  ## executing the jobs
  gfr=$f
 
  if [[ ! -s "$OUTPUT_DIR/$prefix.gfr" ]]
  then
      doIT=1
  else
      doIT=1
      echo "";
      log "QUESTION" "\n$PROGRAM:\t$OUTPUT_DIR/$prefix.gfr exists. Would you like to replace it?"
      read -sn 1 ans
      if [[ "$ans" != 'y' ]]; then
	  doIT=0
      fi
  fi
  
  if [[ $doIT -eq 1 ]]
  then
      FILTER_COMMAND="cd $WORKING_DIR;export FUSIONSEQ_CONFPATH=$FUSIONSEQRC;($ZCAT $gfr"
      while read line 
      do
	  aline=( $line )
	  param=( ${aline[1]} ${aline[2]} )
	  filterFull=${aline[0]}
	  filter=${filterFull#gfr}
	  filter=${filter%Filter}
	  
	  FILTER_COMMAND="${FILTER_COMMAND} | $filterFull ${param[0]} ${param[1]} " 
      done < <( cat $FILTER_LIST )
      if [[ -e $META/$prefix.meta ]];then
	  FILTER_COMMAND="${FILTER_COMMAND} | $PREFIX_DEV""gfrConfidenceValues $META/$prefix"
      else
	  log "WARN" "$prefix.meta not found. Cannot run gfrConfidenceValues nor gfrRandomPairingFilter"
      fi
      FILTER_COMMAND="${FILTER_COMMAND} ) > $OUTPUT_DIR/$prefix.gfr 2> $OUTPUT_DIR/$prefix.gfr.log"
      echo "$FILTER_COMMAND" >> $JOBLIST
  fi
done

echo;echo
NUMJOBS=$(wc -l $JOBLIST | cut -f1 -d " ")
echo There are $NUMJOBS jobs. Here is a sample:
head -n 5 $JOBLIST

echo
NUMPROC=$(grep -c ^processor /proc/cpuinfo)
if [[ $NUMJOBS -gt $NUMPROC ]];then
    let NUMJOBS=$NUMPROC-2
fi
echo
echo -e "export PPSS_DIR=PPSS_DIR_geneFusionFilter_$LABEL;ppss -f $JOBLIST -p $NUMJOBS -c  'bash \$ITEM'"


#PVALUE=$2
#OFFSET_PCR=5
#OFFSET_PROXIMITY=1000
##REPEATMASK_DIR="/home/asboner/annotation/human/hg18_retrotrans/hg18_repeatMasker.interval"
##READLENGTH=$3

