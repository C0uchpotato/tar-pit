#!/bin/bash

DIR=$HOME/.config/tar-pit
USER_CONFIG=$HOME/.config/tar-pit/backup.txt
DEFAULT_CONFIG=$HOME/.config/tar-pit/home_index.txt
CONVERSION=1074000
TAR="$(date '+%m-%d-%y')".tar
COMP_TAR="$(date '+%m-%d-%y')".tar.gz
TARGET=$HOME/tar-pit
#Establish config directory
#TODO; Create config file for user-enabled options

if [ -d "$DIR" ] ; then
	echo "Configuration file exists"
else
	mkdir $DIR
fi

cd $HOME || return 1
#Look for user config file
ls -a $HOME > $DEFAULT_CONFIG

if [ -e "$USER_CONFIG" ] ; then
  echo "User defined config exists"
else
  echo "No user defined config exists"
fi


echo "Configuration complete"
echo "home_index updated"

#Read from either default or user config, then tar respective selections; return 1 for a failure
cd $HOME/.config/tar-pit || return 1
clear
if [ -e $USER_CONFIG ] ; then

  cd $HOME || return 1
  echo "User defined config found"
  echo "Making tar file, this may take a while"
	tar  -ch --verbatim-files-from --files-from=$USER_CONFIG | pv > $TAR
	#tar  -cvhf "$TAR" --verbatim-files-from --files-from=$USER_CONFIG

#TODO; Use pv or some other method to create an ETA or progress bar

else
  echo "No modified config file found, defaulting to tar-ing entire home directory"
  cd $HOME || return 1
  echo "Making tar file, this may take a while"
  tar -ch --files-from=$DEFAULT_CONFIG | pv > $TAR
fi

#Setup target directory, and move resulting tar file
if [ -d $TARGET ] ; then
  echo "Target directory exists"
else
  mkdir $TARGET
fi

mv "$TAR" $TARGET	#TODO; add pv bar
echo "tar file completed"
echo "$TAR moved to $HOME/tar-pit"


cd $TARGET || return 1

#Use ls to dump size of Tar file
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
clear
if [ $CHUNKS -lt 2 ]; then
  echo "This tar file will fit on one DVD, no reason to split, compressing instead"
	pv $TAR | gzip -9 > $COMP_TAR
	echo "Gzip is done compressing, exiting tar-pit"
else
  echo "Splitting tarball, please be patient"	#TODO; Add compression for individual chunks
  tarsplit "$TAR" $CHUNKS
  rm "$TAR"
  echo "tarsplit has finished"
fi

#TODO; Verify chunk sizes
