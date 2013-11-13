#!/bin/bash
set -e
set -u

## creates the joblist to run the fusion pipeline
PROGRAM=$(basename $0)

usage() {
    echo
    echo -e "$PROGRAM:\tUsage:\t$PROGRAM -r reference -f <1|2|3> -c 27 [-u] [-o output_dir] [-l label] [-p \"pattern\"] [-B]"
    echo -e "$PROGRAM:\t\t-r reference\tthe folder of the reference genome"
    echo -e "$PROGRAM:\t\t-f format of the FASTQ file: "
    echo -e "$PROGRAM:\t\t\t\t1: FC.NUM.SAMPLEID.READ.fastq.gz"
    echo -e "$PROGRAM:\t\t\t\t2: SAMPLEID_INDEX_LANE_READ_NUM.fastq.gz"
    echo -e "$PROGRAM:\t\t\t\t3: SAMPLEID_READ.fastq.gz"
    echo -e "$PROGRAM:\t\t-u\t\t[optional]The FASTQ file are NOT compressed (gzipped)"
    echo -e "$PROGRAM:\t\t-l label\t[optional] the label to use for the job file [default: STAR]"
    echo -e "$PROGRAM:\t\t-p \"pattern\"\tthe subset of samples to run [optional]"
    echo -e "$PROGRAM:\t\t-B creates the BAM files [optional]"
    echo -e "\n$PROGRAM:\tEx: $PROGRAM -r ~/genomes/human/hg19/index/star -l some_samples"
    echo -e "$PROGRAM:\tNB: the output will be saved into a GFR.1 sub-directory, which includes also LOG and intraOffsets. If they're not present, they'll be created."
}

log() {
    STATUS=$1
    MESSAGE=$2
    echo -e "[ $(date '+%b %d %R:%S') ] $PROGRAM:\t$STATUS\t$MESSAGE"
}

if [[ $# -lt 4 ]] 
then
    log "ERROR" "Not enough parameters"
    usage
    exit -1
fi

PID="$$"
LABEL="$PID"
WORKING_DIR=$(pwd -P)
OUTPUT_DIR="$WORKING_DIR/STAR"
PATTERN="*"
BAM=""
CAT="zcat"
while getopts "p:l:b:r:o:f:c:uB" optname
  do
  case "$optname" in
      "p")
	  PATTERN=$OPTARG
	  ;;
      "f")
	  FORMAT=$OPTARG
	  ;;
      "c")
	  CHIMERIC_SIZE=$OPTARG
	  ;;
      "u")
	  log "" "Plain text FASTQ file is set"
	  SUFFIX=".fastq"
	  CAT="cat"
	  ;;
      "B")
	  log "" "BAM files will be generated"
	  BAM="--bam"
	  ;;
      "l")
	  LABEL=$OPTARG
	  ;;
      "o")
	  OUTPUT_DIR=$OPTARG
	  ;;
      "r")
	  REFERENCE=$OPTARG
	  if [[ ! -e $REFERENCE ]];then
	      log "ERROR" "Reference does not exist\t $REFERENCE"
	      exit -2
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
log "" "reference is:\t$REFERENCE"
log "" "FORMAT is:\t$FORMAT"
log "" "PATTERN has value:\t$PATTERN"
log "" "Min Chimeric segment has value:\t$CHIMERIC_SIZE"
log "" "Label is:\t$LABEL"
JOBLIST="job_STAR_$LABEL.txt"

echo "Should I continue? [y|n]"
read -sn 1 ans 
if [ "$ans" != "y" ]; then
    exit 0
fi

if [[ ! -e "$OUTPUT_DIR/" ]]; then
    mkdir -p "$OUTPUT_DIR/"
fi


echo -n > $JOBLIST
if [[ $FORMAT -eq 3 ]];then
    SAMPLEID=""
    for l in $WORKING_DIR/$PATTERN.list
    do
 	FIRST_READ=""
	for f in $(cat $l | grep "_[R]*1.fastq*") 
	do
	    FASTQ_DIR=$(dirname $f);log "FASTQ_DIR:" "$FASTQ_DIR";
	    NAME=$(basename $f );log "NAME:"  "$NAME";
	    SAMPLEID=$(echo $NAME | sed 's%\(.*\)_R*\([12]\)_*[0-9]*.fastq\.*g*z*%\1%');log "SAMPLEID" "$SAMPLEID"
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
	for f in $(cat $l | grep "_[R]*2.fastq*") 
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
	    echo "star --genomeDir $REFERENCE --genomeLoad LoadAndKeep --runThreadN 8 --readFilesCommand $CAT --readFilesIn $FIRST_READ $SECOND_READ --outFileNamePrefix $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_ --chimSegmentMin $CHIMERIC_SIZE --outSAMstrandField intronMotif --outSAMunmapped None --outReadsUnmapped fastx --outFilterScoreMinOverLread 0.85;samtools view -@ 8 -Shb $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.sam > $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.bam 2> $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.bam.log;if [[ \$(samtools view -Sc $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.sam) != \$(samtools view -c $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.bam) ]];then printf \"$OUTPUT_DIR/$(basename $l .list)/$SAMPLEID\\tNOT OK\" > $SAMPLEID.check; else printf \"$OUTPUT_DIR/$(basename $l .list)/$SAMPLEID\\tOK\\nRemoving $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.sam\" > $SAMPLEID.check; rm $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.sam; fi;" >> $JOBLIST
	fi
    done
    
    echo "done"
    echo
    NUMJOBS=$(wc -l $JOBLIST | cut -f1 -d " ")
    echo There are $NUMJOBS jobs. Here is a sample:
    head -n 5 $JOBLIST
    echo
    NUMPROC=$(grep -c ^processor /proc/cpuinfo)
    if [[ $NUMJOBS -gt $NUMPROC ]];then
	let NUMJOBS=$NUMPROC-2
    fi
    echo -e "ipcs\nstar --genomeDir $REFERENCE --genomeLoad LoadAndExit"
    echo -e "export PPSS_DIR=PPSS_DIR_STAR_$LABEL;ppss -f $JOBLIST -p $NUMJOBS -c 'bash \$ITEM'"
    exit 0
fi

##### FORMAT 1/2
for l in $WORKING_DIR/$PATTERN.list
do
    #echo "$l"
    SAMPLE=$(basename "$l" ".list")
    log "INFO" "$SAMPLE";
    if [[ ! -e "$OUTPUT_DIR/$SAMPLE" ]]; then
	mkdir -p "$OUTPUT_DIR/$SAMPLE/"
    fi
    FIRST_READ=""
    for f in $(cat $l | grep "_R1_") 
    do
	FASTQ_DIR=$(dirname $f);#echo "FASTQ_DIR: $FASTQ_DIR";
	NAME=$(basename $f );#echo "NAME: $NAME";
	if [[ $FIRST_READ == "" ]];then
	    FIRST_READ=$f
	else
	    FIRST_READ="$FIRST_READ,$f"
	fi
    done
    SECOND_READ=""
    for f in $(cat $l | grep "_R2_") 
    do
	if [[ $SECOND_READ == "" ]];then
	    SECOND_READ=$f
	else
	    SECOND_READ="$SECOND_READ,$f"
	fi
    done
    #echo -e $FIRST_READ"\n"$SECOND_READ
    


	## the following is for HiSeq et al.
	if [[ $FORMAT -eq 1 ]];then
 	    FC=$(echo $NAME       | sed 's%\(.*\)\.\([0-9]*\)\.\(.*\)_\([12]\)\.fastq.gz%\1%');#echo "FC: $FC";
 	    NUM=$(echo $NAME      | sed 's%\(.*\)\.\([0-9]*\)\.\(.*\)_\([12]\)\.fastq.gz%\2%');#echo "NUM: $NUM";
 	    SAMPLEID=$(echo $NAME | sed 's%\(.*\)\.\([0-9]*\)\.\(.*\)_\([12]\)\.fastq.gz%\3%');#echo "SAMPLEID: $SAMPLEID";
 	    READ=$(echo $NAME     | sed 's%\(.*\)\.\([0-9]*\)\.\(.*\)_\([12]\)\.fastq.gz%\4%');#echo "READ: $READ";
	    if [[ ! -e $OUTPUT_DIR/$SAMPLE/$FC.$NUM.$SAMPLEID/$FC.$NUM.$SAMPLEID""_NoIndex_L001_R2_001_export.txt.gz ]];then
 	#ls $OUTPUT_DIR/$SAMPLE/$FC.$NUM.$SAMPLEID/$FC.$NUM.$SAMPLEID""_NoIndex_L001_R2_001_export.txt.gz
 		if [[ "$READ" == "1" ]];then
 	  		echo "cd $WORKING_DIR;(ELAND_standalone_1.8.pl -if $FASTQ_DIR/$FC.$NUM.$SAMPLEID""_1.fastq.gz -if $FASTQ_DIR/$FC.$NUM.$SAMPLEID""_2.fastq.gz -ref $REFERENCE -it fastq -od $OUTPUT_DIR/$SAMPLE/$FC.$NUM.$SAMPLEID -op $FC.$NUM.$SAMPLEID -rt -ub $BASES -ub  $BASES $BAM --log $OUTPUT_DIR/$SAMPLE/$FC.$NUM.$SAMPLEID.eland.log  ) > $OUTPUT_DIR/$SAMPLE/$FC.$NUM.$SAMPLEID.out.eland.log" >> $JOBLIST  
 		fi
 	    fi
 	else if [[ $FORMAT -eq 2 ]];then
 	    SAMPLEID=$(echo $NAME | sed 's%\(.*\)_\([A-Za-z]*\)_\(L00[1-8]\)_R\([12]\)_\([0-9]*\)\.fastq.gz%\1%');#echo "SAMPLEID: $SAMPLEID";
	    INDEX=$(echo $NAME    | sed 's%\(.*\)_\([A-Za-z]*\)_\(L00[1-8]\)_R\([12]\)_\([0-9]*\)\.fastq.gz%\2%');#echo "INDEX: $INDEX";
	    LANE=$(echo $NAME     | sed 's%\(.*\)_\([A-Za-z]*\)_\(L00[1-8]\)_R\([12]\)_\([0-9]*\)\.fastq.gz%\3%');#echo "LANE: $LANE";
 	    READ=$(echo $NAME     | sed 's%\(.*\)_\([A-Za-z]*\)_\(L00[1-8]\)_R\([12]\)_\([0-9]*\)\.fastq.gz%\4%');#echo "READ: $READ";
 	    NUM=$(echo $NAME      | sed 's%\(.*\)_\([A-Za-z]*\)_\(L00[1-8]\)_R\([12]\)_\([0-9]*\)\.fastq.gz%\5%');#echo "NUM: $NUM";
	    
	    if [[ -s $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.bam || -s  $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.sam ]];then
		#echo $SAMPLEID;
		continue;
	    fi
	    echo "star --genomeDir $REFERENCE --genomeLoad LoadAndKeep --runThreadN 8 --readFilesCommand $CAT --readFilesIn $FIRST_READ $SECOND_READ --outFileNamePrefix $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_ --chimSegmentMin $CHIMERIC_SIZE --outSAMstrandField intronMotif --outSAMunmapped None --outReadsUnmapped fastx --outFilterScoreMinOverLread 0.85;samtools view  -@ 8 -Shb $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.sam > $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.bam 2> $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_sam2bam.log;if [[ \$(samtools view -Sc $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.sam) != \$(samtools view -c $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.bam) ]];then printf \"$OUTPUT_DIR/$(basename $l .list)/$SAMPLEID\\tNOT OK\" > $SAMPLEID.check; else printf \"$OUTPUT_DIR/$(basename $l .list)/$SAMPLEID\\tOK\\nRemoving $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.sam\" > $SAMPLEID.check; rm $OUTPUT_DIR/$(basename $l .list)/$SAMPLEID""_Aligned.out.sam; fi; " >> $JOBLIST
	fi
	fi
done




echo "done"
echo
NUMJOBS=$(wc -l $JOBLIST | cut -f1 -d " ")
echo There are $NUMJOBS jobs. Here is a sample:
head -n 5 $JOBLIST
echo
NUMPROC=$(grep -c ^processor /proc/cpuinfo)
if [[ $NUMJOBS -gt $NUMPROC ]];then
    let NUMJOBS=$NUMPROC-2
fi
echo -e "ipcs\nstar --genomeDir $REFERENCE --genomeLoad LoadAndExit"
echo -e "export PPSS_DIR=PPSS_DIR_STAR_$LABEL;ppss -f $JOBLIST -p $NUMJOBS -c 'bash \$ITEM'"



########
## ORIGINAL HiSeq
##	FC=$(echo $NAME | sed 's%\(.*\)\.\([1-8]\)\.\([ATCG]\{8\}\)_\([12]\)\.fastq.gz%\1%');#echo "FC: $FC";
## 	NUM=$(echo $NAME | sed 's%\(.*\)\.\([1-8]\)\.\([ATCG]\{8\}\)_\([12]\)\.fastq.gz%\2%');#echo "NUM: $NUM";
# 	SAMPLEID=$(echo $NAME | sed 's%\(.*\)\.\([1-8]\)\.\([ATCG]\{8\}\)_\([12]\)\.fastq.gz%\3%');#echo "SAMPLEID: $SAMPLEID";
# 	READ=$(echo $NAME | sed 's%\(.*\)\.\([1-8]\)\.\([ATCG]\{8\}\)_\([12]\)\.fastq.gz%\4%');#echo "READ: $READ";
