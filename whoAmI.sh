#!/bin/bash
# Name: /tmp/demo.bash : 
# Purpose: Tell in what directory $0 is stored in
# Warning: Not tested for portability 
# ------------------------------------------------


#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  TARGET="$(readlink "$SOURCE")"
  if [[ $SOURCE == /* ]]; then
    echo "SOURCE '$SOURCE' is an absolute symlink to '$TARGET'"
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    echo "SOURCE '$SOURCE' is a relative symlink to '$TARGET' (relative to '$DIR')"
    SOURCE="$DIR/$TARGET" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done
echo "SOURCE is '$SOURCE'"
RDIR="$( dirname "$SOURCE" )"
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
if [ "$DIR" != "$RDIR" ]; then
  echo "DIR '$RDIR' resolves to '$DIR'"
fi
echo "DIR is '$DIR'"






 
## who am i? ##
#_script="$(readlink -f ${BASH_SOURCE[0]})"
 
## Delete last component from $_script ##
#_base="$(dirname $_script)"
 
## Okay, print it ##
#echo "Script name : $_script"
#echo "Current working dir : $PWD"
#echo "Script location path (dir) : $_base"
