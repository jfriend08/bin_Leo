#!/bin/bash
PROGRAM=$(basename $0)

if [[ $# -lt 2 ]] 
then
	echo "Usage $PROGRAM \"pattern\" <mrf|gz>"
	echo "where 'pattern' doesn't contain .mrf.gz and must be quoted"
	echo "Ex: $PROGRAM \"0s*\"  gz"
	exit -1
fi
PATTERN=$1
SUFFIX=$2
CAT="zcat"
PID="$$"
LABEL="$PID"
JOBLIST="job_META.$LABEL.txt"
if [[ "$SUFFIX" == "mrf" ]]
    then
    CAT="cat"
    SUFFIX="mrf"
else if [[ "$SUFFIX" != "gz" ]];then
    	echo "Suffix must be either mrf or gz"
    	exit -1
     else	
	SUFFIX="mrf.gz"
     fi
fi
#echo $PATTERN.$SUFFIX
echo -n "" > $JOBLIST
for f in $PATTERN.$SUFFIX
do
  prefix=$(basename "$f" ".$SUFFIX");
  echo "Sample $prefix"
  if [[ -s "$prefix.meta" ]] 
  then
      echo "$prefix.meta already exists. Skip?"
      read -sn 1 ans
      if [[ "$ans" == 'y' ]]; then
	  continue
      fi
  fi
  id=${prefix//./_}
  id=${id//-/_}
  echo "export MAPPED_$id=\$($CAT $prefix.$SUFFIX | cut -f1 | grep -v \"AlignmentBlock\" | grep -v \"^#\" | wc -l);printf \"Mapped_reads\\t%d\\n\" \$MAPPED_$id > $prefix.meta" >> $JOBLIST
done
NUMJOBS=$(wc -l $JOBLIST | cut -f1 -d " ")
echo There are $NUMJOBS jobs. Here is a sample:
head -n 5 $JOBLIST
echo
NUMPROC=$(grep -c ^processor /proc/cpuinfo)
if [[ $NUMJOBS -gt $NUMPROC ]];then
    let NUMJOBS=$NUMPROC-2
fi
echo -e "export PPSS_DIR=PPSS_DIR_meta_$LABEL;ppss -f $JOBLIST -p $NUMJOBS -c 'bash \$ITEM'"
