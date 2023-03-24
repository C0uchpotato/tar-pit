#!/bin/bash
USER_CONFIG=$HOME/.config/tar-pit/conf
CONFIG_DIR=$HOME/.config/tar-pit
CONVERSION=1074000

if [ -d "$CONFIG_DIR" ] ; then
	echo "Configuration file exists"
else
	mkdir $CONFIG_DIR
fi

if [ -e "$USER_CONFIG" ] ; then
	echo "User modified config found"
	source $HOME/.config/tar-pit/conf
else
	echo "No user modified config found, creating a default"
	touch $USER_CONFIG

	echo "
	#!/bin/bash

	#This defines the compression level for gzip at the end of the script, acceptable values are between 1-9
	export COMPRESSION_LEVEL=-6

	#Will be used in future releases
	export EXTERNAL_STORAGE=

	#Will be used in future releases
	export DVD_DRIVE=/mnt/cdrom

	#Will be used in future releases
	export AUTO_BURN=false

	#Will be used in future releases
	export AUTO_CP_TO_EXTERN=false

	#Path to the file which lists all files to be backed up
	export USER_DEFINED_BACKUPS=$HOME/.config/tar-pit/backup.txt

	#List of all files in $HOME
	export DEFAULT_BACKUPS=$HOME/.config/tar-pit/home_index.txt

	#Names the tar and tar.gz files created
	export TAR=$(date '+%m-%d-%y').tar
	export COMP_TAR=$(date '+%m-%d-%y').tar.gz

	#Directory where output files are stored
	export TARGET=$HOME/tar-pit

	" >> $USER_CONFIG

fi

cd $HOME || exit 1
#Look for user config file
ls -a $HOME > $DEFAULT_BACKUPS

if [ -e "$USER_DEFINED_BACKUPS" ] ; then
  echo "User has defined directories to backup"
else
  echo "User has not definied directories to backup"
fi


echo "Configuration complete"
echo "home_index updated"

#Read from either default or user config, then tar respective selections; exit 1 for a failure
cd $HOME/.config/tar-pit || exit 1

if [ -e $USER_DEFINED_BACKUPS ] ; then

  cd $HOME || exit 1
  echo "User defined config found"
  echo "Making tar file, this may take a while"
	tar  -ch --verbatim-files-from --files-from=$USER_DEFINED_BACKUPS | pv > $TAR
	#tar  -cvhf "$TAR" --verbatim-files-from --files-from=$USER_DEFINED_BACKUPS
	clear

else
  echo "No modified config file found, defaulting to tar-ing entire home directory"
  cd $HOME || exit 1
  echo "Making tar file, this may take a while"
  tar -ch --files-from=$DEFAULT_BACKUPS | pv > $TAR
	clear
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


cd $TARGET || exit 1

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
#
if [ $CHUNKS -lt 2 ]; then
  echo "This tar file will fit on one DVD, no reason to split, compressing at compression level $COMPRESSION_LEVEL"
	pv $TAR | gzip $COMPRESSION_LEVEL > $COMP_TAR
	rm $TAR
	clear
	echo "Gzip is done compressing, exiting tar-pit"
else
  echo "Splitting tarball, please be patient"	#TODO; Add compression for individual chunks
  tarsplit "$TAR" $CHUNKS
  rm "$TAR"
  echo "tarsplit has finished"
fi

#TODO; Verify chunk sizes
