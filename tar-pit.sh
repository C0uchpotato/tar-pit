#!/bin/bash

DIR=~/.config/tar-pit
USER_CONFIG=~/.config/tar-pit/backup.txt
DEFAULT_CONFIG=~/.config/tar-pit/home_index.txt
CONVERSION=1074000
TAR="$(date '+%m-%d-%y')".tar
TARGET=~/tar-pit
#Establish config directory
#TODO; Create config file for user-enabled options

if [ -d "$DIR" ] ; then
	echo "Configuration file exists"
else
	mkdir $DIR
fi

cd ~ || return 1
#Look for user config file
ls -a ~ > $DEFAULT_CONFIG

if [ -e "$USER_CONFIG" ] ; then
  echo "User defined config exists"
else
  echo "No user defined config exists"
fi


echo "Configuration complete"
echo "home_index updated"

#Read from either default or user config, then tar respective selections
cd ~/.config/tar-pit || return 1

if [ -e $USER_CONFIG ] ; then

  cd ~ || return 1
  echo "User defined config found"
  echo "Making tar file, this may take a while"
  tar  -cvhf "$TAR" --verbatim-files-from --files-from=$USER_CONFIG ##TODO: Progress bar

#need to use pv or some other method to create an ETA or progress bar

else
  echo "No modified config file found, defaulting to "tar"-ing entire home directory"
  cd ~ || return 1
  echo "Making tar file, this may take a while"
  tar -cvhf "$TAR" --files-from=$DEFAULT_CONFIG ##TODO: Progress bar
fi

#Setup target directory, and move resulting tar file
if [ -d $TARGET ] ; then
  echo "Target directory exists"
else
  mkdir $TARGET
fi

mv "$TAR" $TARGET
echo "tar file completed"
echo "$TAR moved to ~/tar-pit"


cd $TARGET || return 1

#Use du to dump size of Tar file
ls -s "$TAR" > chunk_size.txt

#Use awk and bash to strip all non-numerical characters
#This also eliminates the file name from chunk_size.txt

TAR_SIZE=$(awk '{print $1}' chunk_size.txt)
TAR_SIZE=${TAR_SIZE//[^0-9]/}
rm chunk_size.txt


#Divide TAR_SIZE by conversion rate for bytes -> GB
#Store final (GB) size of Tar file in $TAR_SIZE
TAR_SIZE=$(( TAR_SIZE / CONVERSION))

#Determine how many chunks needed for tarsplit
#Add one to ensure Tar file will always be < 7.9, and to ensure CHUNKS > 0
CHUNKS=$(( TAR_SIZE / 10))
CHUNKS=$(( CHUNKS + 1))

if [ $CHUNKS -lt 2 ]; then
  echo "This tar file will fit on one DVD, no reason to split, compressing instead"
	gzip -7 "$TAR"
else
  echo "Splitting tarball, please be patient"	#TODO; Add compression for individual chunks
  tarsplit "$TAR" $CHUNKS
  rm "$TAR"
  echo "tarsplit has finished"
fi

#TODO; Verify chunk sizes
