#!/bin/bash
set -e
set -u
. /home/asboner/bin/common_functions.sh

## creates the joblist to run the fusion pipeline
PROGRAM=$(basename $0)

usage() {
    echo
    echo -e "$PROGRAM:\tUsage:\t$PROGRAM -i input_dir [-l label] [-p \"pattern\"] [-F] [-M] [-S]"
    echo -e "$PROGRAM:\t\t-i input_dir\tthe folder where the STAR same file(s) are (STAR/SAMPLE/)."
    echo -e "$PROGRAM:\t\t-l label\t[optional] the label to use for the job file "
    echo -e "$PROGRAM:\t\t-p \"pattern\"\t[optional the subset of samples to run: [default: *]"
    echo -e "$PROGRAM:\t\t-F force\t[optional] Force the creation of a sorted.bam even if already present [default: FALSE]"
    echo -e "$PROGRAM:\t\t-M DO NOT generate the MRF files [default: TRUE]"
    echo -e "$PROGRAM:\t\t-S The Aligned.out file is a SAM file [default: FALSE]"
    echo -e "\n$PROGRAM:\tEx: $PROGRAM mergeSTARbam.sh -i STAR -p \"Sample_*\" -l someSamples"
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
PATTERN="*"
BAM=""
CAT="zcat"
FORCE="FALSE"
PICARD_DIR="/pbtech_mounts/homesA/asboner/Software/picard-tools-1.85"
SAMSUFFIX="bam"
CREATE_MRF="TRUE"
while getopts "i:p:l:b:FMS" optname
  do
  case "$optname" in
      "i")
	  INPUT_DIR=$(readlink -m $OPTARG)
	  if [[ ! -e $INPUT_DIR ]];then
	      log "ERROR" "$INPUT_DIR does not exists"
	      usage
	      exit -1
	  fi
	  ;;
      "p")
	  PATTERN=$OPTARG
	  ;;
      "F")
	  log "" "sorted.bam file will be regenerated"
	  FORCE="TRUE"
	  ;;
      "l")
	  LABEL=$OPTARG
	  ;;
      "o")
	  OUTPUT_DIR=$OPTARG
	  ;;
      "M")
	  CREATE_MRF="FALSE"
	  ;;
      "S")
	 SAMSUFFIX="sam"
	  ;;
      "?")
	  log "ERROR" "Unknown option $OPTARG"
	  usage
	  exit -1
	  ;;
      ":")
	  log "ERROR" "No argument value for option $OPTARG"
	  usage
	  exit -1
	  ;;
      *)
      # Should not occur
	  log "ERROR" "Unknown error while processing options"
	  usage
	  exit -1
	  ;;
  esac    
done
log "" "INPUT_DIR has value:\t$INPUT_DIR"
log "" "PATTERN has value:\t$PATTERN"
log "" "FORCE has value:\t$FORCE"
log "" "Label is:\t$LABEL"
log "" "CREATE_MRF is:\t$CREATE_MRF"
JOBLIST="job_mergeSTAR_$LABEL.txt"

echo "Should I continue? [y|n]"
read -sn 1 ans 
if [ "$ans" != "y" ]; then
    exit 0
fi


echo -n > $JOBLIST

for ROOT_DIR in $(find $INPUT_DIR -maxdepth 1 -type d  -name "$PATTERN*")
do
    
    SAMPLE=$(basename "$ROOT_DIR");#log "INFO" "ROOT_DIR\t$ROOT_DIR"
    BAMCOUNT=$(find $ROOT_DIR -type f -size +0 -name "*_Aligned.out.$SAMSUFFIX" | wc -l );#log "INFO" "There is/are $BAMCOUNT SAM/BAM files."
#    if [[ $BAMCOUNT -ne 1 ]];then
#	continue;
#    fi	
    BAMFILES=$(find $ROOT_DIR -type f -size +0 -name "*_Aligned.out.$SAMSUFFIX");#log "INFO" "BAMFILES:\n$BAMFILES"
    for BAMFILE in $BAMFILES 
    do
	MAIN_DIR=$(dirname $BAMFILE);#log "INFO" "MAIN_DIR:\t$MAIN_DIR"
	if [[ ! -e $BAMFILE ]];then
	    log "ERROR" "BAM output doesn't exists:***\t$BAMFILE\t****"
	    exit -2
	fi
	SAMPLEID=$(basename "$BAMFILE" | sed 's%\(.*\)_Aligned.out.[bs]am%\1%');#log "INFO" "SampleIDs:\t$SAMPLEID" ## to add [bs]am when completed
	if [[ -s "$MAIN_DIR/$SAMPLEID"".sorted.bam" && "$FORCE" == "FALSE" ]];then
	    continue;
	fi
	#log "INFO" "SAMPLE: $SAMPLE";
	#for f in "$ROOT_DIR/*_Aligned.out.[bs]am" ## ## to add [bs]am when completed
	#do
	#SAMPLEID=$(basename $BAMFILE | sed 's%\(.*\)_Aligned.out.[bs]am%\1%');log "INFO" "SampleID:\t$SAMPLEID"
	SAM_FLAG=$(basename $BAMFILE | sed 's%\(.*\)_Aligned.out.\([bs]am\)%\2%');#log "INFO" "SAM_FLAG ($SAMPLEID):\t$SAM_FLAG"
	if [[ $SAM_FLAG == "sam" ]];then
	    SAM_FLAG="-S"
	else
	    SAM_FLAG=""
	fi
	
	SAM=$(basename $BAMFILE);#log "INFO" "$SAM"
	CHIM=$SAMPLEID"_Chimeric.out.sam";#log "INFO" "$CHIM"
	CHIMB=$SAMPLEID"_Chimeric.out.bam";#log "INFO" "$CHIMB"	
	
	JUNC=$SAMPLEID"_Chimeric.out.junction";#log "INFO" "$JUNC"
	if [[ (! -e $MAIN_DIR/$CHIM) && ( ! -e  $MAIN_DIR/$CHIMB ) ]]; then
	    log "ERROR" "Chimeric sam file does not exists. Skipping:\n$MAIN_DIR/$CHIM\n$MAIN_DIR/$CHIMB"
	    continue
	fi
	if [[ ! -e $MAIN_DIR/$JUNC ]]; then
	    log "ERROR" "Chimeric junction file does not exists. Skipping"
	    continue
	fi
### with PICARD MergeSam - deprecated	echo "cd $ROOT_DIR; (grep 'p' $JUNC | cut -f10 > $SAMPLEID""_IDlist.txt); Split_FJR.pl $CHIM $SAMPLEID""_IDlist.txt $ROOT_DIR &> $SAMPLEID""_split.log; (samtools view -@ 8 -bh $SAM_FLAG -F 256 $SAM ) > $SAMPLEID""_filteredAlign.bam 2> $SAMPLEID""_filteredAlign.log; (samtools view -@ 8 -Sbh -F 256 $SAMPLEID""_chimericPE.sam) > $SAMPLEID""_chimericPE_filtered.bam 2> $SAMPLEID""_chimericPE_filtered.log; (java -Xmx16g -jar $PICARD_DIR/MergeSamFiles.jar MERGE_SEQUENCE_DICTIONARIES=true USE_THREADING=false MAX_RECORDS_IN_RAM=5000000 INPUT=$SAMPLEID""_filteredAlign.bam INPUT=$SAMPLEID""_chimericPE_filtered.bam SORT_ORDER=queryname VALIDATION_STRINGENCY=LENIENT TMP_DIR=./$SAMPLEID""_tmp OUTPUT=$SAMPLEID""_Merged.bam ) 2> $SAMPLEID.MergeSam.log; (samtools view -@ 8 $SAMPLEID""_Merged.bam | sam2mrf | mrfSorter | gzip ) > $SAMPLEID.mrf.gz 2> $SAMPLEID.mrf.log; (samtools sort -@ 8 -m 2G $SAMPLEID""_Merged.bam $SAMPLEID"".sorted) 2> $SAMPLEID"".sorted.log; samtools index $SAMPLEID"".sorted.bam; if [[ \$(samtools view -c $SAMPLEID""_Merged.bam) != \$(samtools view -c $SAMPLEID"".sorted.bam) ]];then printf \"$SAMPLEID\\tNOT OK\" > $SAMPLEID.sorting.check; else printf \"$SAMPLEID\\tOK\\nRemoving $SAMPLEID""_Merged.bam and associated files\" > $SAMPLEID.sorting.check; rm -r $SAMPLEID""_Merged.bam $SAMPLEID""_filteredAlign.bam $SAMPLEID""_chimericPE_filtered.bam $SAMPLEID""_tmp; fi;samtools view -@ 8 -Shb $SAMPLEID""_FJR.sam > $SAMPLEID""_FJR.tmp.sam; samtools sort -@ 8 $SAMPLEID""_FJR.tmp.sam $SAMPLEID""_FJR  2> $SAMPLEID""_FJR.bam.log; samtools index $SAMPLEID""_FJR.bam; (samtools view -@ 8 -Shb $SAMPLEID""_Chimeric.out.sam > $SAMPLEID""_Chimeric.out.bam ) 2> $SAMPLEID""_Chimeric.out.bam.log; if [[ \$(samtools view -c $SAMPLEID""_Chimeric.out.bam) -eq \$(samtools view -Sc $SAMPLEID""_Chimeric.out.sam) ]];then mv $SAMPLEID""_Chimeric.out.sam $SAMPLEID""_Chimeric.out.sam.old ; fi;rm $SAMPLEID""_FJR.sam;"      >> $JOBLIST
	if [[ $CREATE_MRF == "TRUE" ]];then
	    echo "cd $MAIN_DIR; (grep 'p' $JUNC | cut -f10 > $SAMPLEID""_IDlist.txt); Split_FJR.pl $CHIM $SAMPLEID""_IDlist.txt $MAIN_DIR &> $SAMPLEID""_split.log; (samtools view -@ 8 -bh $SAM_FLAG -F 256 $SAM ) > $SAMPLEID""_filteredAlign.bam 2> $SAMPLEID""_filteredAlign.log; (samtools view -@ 8 -Sbh -F 256 $SAMPLEID""_chimericPE.sam) > $SAMPLEID""_chimericPE_filtered.bam 2> $SAMPLEID""_chimericPE_filtered.log; samtools view $SAM_FLAG -H $SAM > $SAM.header; (samtools merge -n -@ 8 -h $SAM.header $SAMPLEID""_Merged.bam $SAMPLEID""_filteredAlign.bam $SAMPLEID""_chimericPE_filtered.bam) 2> $SAMPLEID.MergeSam.log; (samtools view -@ 8 $SAMPLEID""_Merged.bam | sam2mrf | mrfSorter | gzip ) > $SAMPLEID.mrf.gz 2> $SAMPLEID.mrf.log; (samtools sort -@ 8 -m 2G $SAMPLEID""_Merged.bam $SAMPLEID"".sorted) 2> $SAMPLEID"".sorted.log; samtools index $SAMPLEID"".sorted.bam; if [[ \$(samtools view -c $SAMPLEID""_Merged.bam) != \$(samtools view -c $SAMPLEID"".sorted.bam) ]];then printf \"$SAMPLEID\\tNOT OK\" > $SAMPLEID.sorting.check; else printf \"$SAMPLEID\\tOK\\nRemoving $SAMPLEID""_Merged.bam and associated files\" > $SAMPLEID.sorting.check; rm -r $SAM.header $SAMPLEID""_Merged.bam $SAMPLEID""_filteredAlign.bam $SAMPLEID""_chimericPE_filtered.bam $SAMPLEID""_tmp; fi;samtools view -@ 8 -Shb $SAMPLEID""_FJR.sam > $SAMPLEID""_FJR.tmp.bam; samtools sort -@ 8 $SAMPLEID""_FJR.tmp.bam $SAMPLEID""_FJR  2> $SAMPLEID""_FJR.bam.log; samtools index $SAMPLEID""_FJR.bam; (samtools view -@ 8 -Shb $SAMPLEID""_Chimeric.out.sam > $SAMPLEID""_Chimeric.out.bam ) 2> $SAMPLEID""_Chimeric.out.bam.log; if [[ \$(samtools view -c $SAMPLEID""_Chimeric.out.bam) -eq \$(samtools view -Sc $SAMPLEID""_Chimeric.out.sam) ]];then mv $SAMPLEID""_Chimeric.out.sam $SAMPLEID""_Chimeric.out.sam.old ; fi;rm $SAMPLEID""_FJR.sam;"      >> $JOBLIST
	else
	    echo "cd $MAIN_DIR; (grep 'p' $JUNC | cut -f10 > $SAMPLEID""_IDlist.txt); Split_FJR.pl $CHIM $SAMPLEID""_IDlist.txt $MAIN_DIR &> $SAMPLEID""_split.log; (samtools view -@ 8 -bh $SAM_FLAG -F 256 $SAM ) > $SAMPLEID""_filteredAlign.bam 2> $SAMPLEID""_filteredAlign.log; (samtools view -@ 8 -Sbh -F 256 $SAMPLEID""_chimericPE.sam) > $SAMPLEID""_chimericPE_filtered.bam 2> $SAMPLEID""_chimericPE_filtered.log; samtools view $SAM_FLAG -H $SAM > $SAM.header; (samtools merge -@ 8 -h $SAM.header $SAMPLEID""_Merged.bam $SAMPLEID""_filteredAlign.bam $SAMPLEID""_chimericPE_filtered.bam) 2> $SAMPLEID.MergeSam.log; samtools sort $SAMPLEID""_Merged.bam $SAMPLEID.sorted; samtools index $SAMPLEID"".sorted.bam;  if [[ \$(samtools view -c $SAMPLEID""_Merged.bam) != \$(samtools view -c $SAMPLEID"".sorted.bam) ]];then printf \"$SAMPLEID\\tNOT OK\" > $SAMPLEID.sorting.check; else printf \"$SAMPLEID\\tOK\\nRemoving $SAMPLEID""_Merged.bam and associated files\" > $SAMPLEID.sorting.check; rm -r $SAM.header $SAMPLEID""_Merged.bam $SAMPLEID""_filteredAlign.bam $SAMPLEID""_chimericPE_filtered.bam $SAMPLEID""_tmp; fi; rm -r $SAM.header $SAMPLEID""_filteredAlign.bam $SAMPLEID""_chimericPE_filtered.bam;samtools view -@ 8 -Shb $SAMPLEID""_FJR.sam > $SAMPLEID""_FJR.tmp.bam; samtools sort -@ 8 $SAMPLEID""_FJR.tmp.bam $SAMPLEID""_FJR  2> $SAMPLEID""_FJR.bam.log; samtools index $SAMPLEID""_FJR.bam; (samtools view -@ 8 -Shb $SAMPLEID""_Chimeric.out.sam > $SAMPLEID""_Chimeric.out.bam ) 2> $SAMPLEID""_Chimeric.out.bam.log; if [[ \$(samtools view -c $SAMPLEID""_Chimeric.out.bam) -eq \$(samtools view -Sc $SAMPLEID""_Chimeric.out.sam) ]];then mv $SAMPLEID""_Chimeric.out.sam $SAMPLEID""_Chimeric.out.sam.old ; fi;rm $SAMPLEID""_FJR.sam;"      >> $JOBLIST
	fi
    done
    
done

echo "done"
echo
NUMJOBS=$(wc -l $JOBLIST | cut -f1 -d " ")
echo There are $NUMJOBS jobs. Here is a sample:
head -n 2 $JOBLIST
echo
NUMPROC=$(grep -c ^processor /proc/cpuinfo)
if [[ $NUMJOBS -gt $NUMPROC ]];then
    let NUMJOBS=$NUMPROC-2
fi
echo -e "export PPSS_DIR=PPSS_DIR_mergeSTARBAM_$LABEL;ppss -f $JOBLIST -p $NUMJOBS -c 'bash \$ITEM'"



########
## ORIGINAL HiSeq
##	FC=$(echo $NAME | sed 's%\(.*\)\.\([1-8]\)\.\([ATCG]\{8\}\)_\([12]\)\.fastq.gz%\1%');#echo "FC: $FC";
## 	NUM=$(echo $NAME | sed 's%\(.*\)\.\([1-8]\)\.\([ATCG]\{8\}\)_\([12]\)\.fastq.gz%\2%');#echo "NUM: $NUM";
# 	SAMPLEID=$(echo $NAME | sed 's%\(.*\)\.\([1-8]\)\.\([ATCG]\{8\}\)_\([12]\)\.fastq.gz%\3%');#echo "SAMPLEID: $SAMPLEID";
# 	READ=$(echo $NAME | sed 's%\(.*\)\.\([1-8]\)\.\([ATCG]\{8\}\)_\([12]\)\.fastq.gz%\4%');#echo "READ: $READ";
