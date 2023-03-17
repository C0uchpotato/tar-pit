#!/bin/bash
DEFAULT_CONFIG=~/.config/tar-pit/home_index.txt
USER_CONFIG=~/.config/tar-pit/backup.txt
CONVERSION=1000000000
TAR=~/Archive/out.tar

cd ~/Archive

#Use du to dump size of Tar file
du -b $TAR > chunk_size.txt

#Use awk and bash to strip all non-numerical characters

TAR_SIZE=$(awk '{$1=$1;print}' chunk_size.txt)
TAR_SIZE=${TAR_SIZE//[^0-9]/}


#Divide TAR_SIZE by conversion rate for bytes -> GB
#Store final (GB) size of Tar file in $TAR_SIZE
TAR_SIZE=`expr $TAR_SIZE / $CONVERSION`
#TAR_SIZE=$(echo $(( TAR_SIZE / $CONVERSION )))

#Determine how many chunks needed for tarsplit
#Add one to ensure Tar file will always be < 7.9
CHUNKS=`expr $TAR_SIZE / 7`
CHUNKS=`expr $CHUNKS + 1`

if [ $CHUNKS -lt 2 ]; then
  echo "This tar file will fit on one CD, no reason to split"
else
  echo "Splitting tarball, please be patient"
  tarsplit $TAR $CHUNKS
  rm $TAR
fi
