#!/bin/bash 
. /home/asboner/bin/common_functions.sh


PROGRAM=$(basename $0)
usage() {
    log "USAGE" "$PROGRAM -f filter.list -r fusionseqrc -p unfilteredGfrFile [-m meta_dir] [-u] [-D] [-o output_dir] [-l label]\n"
    log "USAGE" "$PROGRAM:\t-f\ttext file with the list of filters to use, one per line."
    log "USAGE" "$PROGRAM:\t-r\tthe .fusionseqrc that must be used for the analysis"
    log "USAGE" "$PROGRAM:\t-p\tthe unfiltered GFR file: file.1.gfr.gz (without .1.gfr.gz)"
    log "USAGE" "$PROGRAM:\t-m meta_dir\tthe folder where the MRF file(s) is." 
    log "USAGE" "$PROGRAM:\t-D\tif set, then development version is used [optional (default: not set)]"
    log "USAGE" "$PROGRAM:\t-u\tif set, then the GFR.1 files are not compressed [optional (default: not set)]"
    log "USAGE" "$PROGRAM:\t-o output_dir\t[optional] the output directory for the 1.gfr files [default: ./]\n"
    log "USAGE" "s$PROGRAM:\t-l\tthe label to use for the job_list file name [optional (default:fusion.filters)]"
    log "USAGE" "\n$PROGRAM: Example:\t\t\t$PROGRAM -f filter.list -d GFR.1 -p \"*\" -r hg18/.fusionseqrc\n\n"
}


## creates the joblist to run the fusion pipeline

if [[ $# -lt 6 ]] 
then
	log "ERROR" "Not enough parameters"
	usage
	exit -1
fi
GFR1SUFFIX=".1.gfr.gz"
ZCAT="zcat"
LABEL="$$"
PATTERN="*"
OUTPUT_DIR="./"
PREFIX_DEV=""
while getopts "Dp:f:r:l:m:o:u" optname
  do
  case "$optname" in
      "p")
	  PATTERN=$OPTARG
	  ;;
      "f")
	  FILTER_LIST=$OPTARG
	  if [[ ! -e "$FILTER_LIST" ]];then
	      log "ERROR" "The list of filters does not exist:\t$FILTER_LIST"
	      usage
	      exit -2
	  fi
	  ;;
      "o")
	  OUTPUT_DIR=$OPTARG
	  ;;
      "m")
	  META=$OPTARG	  
	  if [[ ! -e $META ]];then
	      log "ERROR" "Cannot find META directory:\t$META"
	      exit -3
	  fi
	  ;;
      "r")
	  FUSIONSEQRC=$OPTARG
	  if [[ ! -e $FUSIONSEQRC ]];then
	      log "ERROR" "Cannot find FUSIONSEQRC file:\t$FUSIONSEQRC"
	      exit -3
	  fi
	  ;;
      "u")
	  log "" "Plain text GFR.1 file(s) is set"
	  GFR1SUFFIX=".1.gfr"
	  ZCAT="cat"
	  ;;
      "l") 
	  LABEL="$OPTARG"
	  ;;
      "D")
	  PREFIX_DEV="/home/asboner/Software/fusionseq/bin/"
	  log "INFO" "The DEVELOPMENT version will be used\t$PREFIX_DEV"
	  ;;
      "?")
	  log "ERROR" "Unknown option $optname"
	  ;;
      ":")
	  log "ERROR" "No argument value for option $optname"
	  usage
	  ;;
      *)
      # Should not occur
	  log "ERROR" "Unknown error while processing options"
	  ;;
  esac    
done

log "" "FILTERLIST is:\t$FILTER_LIST"
log "" "FUSIONSEQRC has value:\t$FUSIONSEQRC"
log "" "PATTERN has value:\t$PATTERN"
log "" "META folder is:\t$META"
log "" "LABEL is:\t$LABEL"
log "" "OUTPUT_DIR is:\t$OUTPUT_DIR"


WORKING_DIR=$(pwd)
if [[ ! -e $OUTPUT_DIR ]];then
    mkdir $OUTPUT_DIR
fi
echo

JOBLIST="job_fusion_filter.$LABEL.txt"
echo -n "" > $JOBLIST
gfr=$PATTERN$GFR1SUFFIX ##$files
prefix=$(basename $gfr $GFR1SUFFIX)
log "INFO" "$prefix "
## executing the jobs

FILTER_COMMAND="cd $WORKING_DIR;export FUSIONSEQ_CONFPATH=$FUSIONSEQRC;($ZCAT $gfr"
while read line 
do
    aline=( $line )
    param=( ${aline[1]} ${aline[2]} )
    filterFull=${aline[0]}
    filter=$(basename $filterFull);
    filter=${filter#gfr}
    filter=${filter%Filter}
    if [[ "$filter" == "AnnotationConsistency" ]];then
	filter="$filter.${param[0]}"
    fi
    FILTER_COMMAND="${FILTER_COMMAND} | $filterFull ${param[0]} ${param[1]} ) > $prefix.$filter.gfr 2> $prefix.$filter.gfr.log;  (cat $prefix.$filter.gfr " 
done < <( cat $FILTER_LIST )

if [[ -e "$META/$prefix".meta ]];then
    FILTER_COMMAND="${FILTER_COMMAND} | $PREFIX_DEV""gfrConfidenceValues $META/$prefix"
else
    log "WARN" "$prefix.meta not found. Cannot run gfrConfidenceValues"
fi
FILTER_COMMAND="${FILTER_COMMAND} ) > $prefix.gfr"
echo "$FILTER_COMMAND" >> $JOBLIST


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
echo -e "ppss -l ppss.log$LABEL -f $JOBLIST -p $NUMJOBS -c  'bash \$ITEM'"


#PVALUE=$2
#OFFSET_PCR=5
#OFFSET_PROXIMITY=1000
##REPEATMASK_DIR="/home/asboner/annotation/human/hg18_retrotrans/hg18_repeatMasker.interval"
##READLENGTH=$3

