#!/bin/bash
USER_CONFIG=$HOME/.config/tar-pit/conf
CONFIG_DIR=$HOME/.config/tar-pit
CONVERSION=1074000

if [ -d "$CONFIG_DIR" ] ; then
	echo "Configuration file exists"
else
	mkdir "$CONFIG_DIR"
fi

if [ -e "$USER_CONFIG" ] ; then
	echo "User modified config found"
	source $HOME/.config/tar-pit/conf
else
	echo "No user modified config found, creating a default"
	touch "$USER_CONFIG"

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

	#Split files to fit on 7.9 GB dvd's
	export SPLIT=false
	" >> "$USER_CONFIG"

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

#Pacmanfile option for arch users
if [ pacmanfile != false ] ; then
	if pacman -Qqm pacmanfile ; then
		echo "pacmanfile is installed"
	else
		echo "please install pacmanfile"
	fi
	pacmanfile dump
	echo "pacmanfile dump complete. Your current packages have been written to $HOME/.config/pacmanfile/pacmanfile-dumped.txt"
else
	echo "Pacmanfile option not selected"
fi


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

mv "$TAR" $TARGET
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
CHUNKS=$(( TAR_SIZE / 7))
CHUNKS=$(( CHUNKS + 1))

#Check if user wants files split, if true then split to ~7GB chunks, if false, compress using $COMPRESSION_LEVEL
if [ "$SPLIT" = true ]; then
	if [ $CHUNKS -lt 2 ]; then
	  echo "This tar file will fit on one DVD, no reason to split, compressing at compression level $COMPRESSION_LEVEL"
		pv $TAR | gzip $COMPRESSION_LEVEL > $COMP_TAR
		rm $TAR
		clear
			if [ $SECONDARY_TARGET != "null" ]; then
				cp $COMP_TAR $SECONDARY_TARGET
			else
				print "No secondary target"
			fi
		echo "Gzip is done compressing, exiting tar-pit"
	else
	  echo "Splitting tarball, please be patient"	#TODO; Add compression for individual chunks
	  tarsplit "$TAR" $CHUNKS		#TODO; Verify chunk size
	  rm "$TAR"
	  echo "tarsplit has finished"
	fi
else
	echo "The file of $TAR_SIZE will be compressed at $COMPRESSION_LEVEL"
	pv $TAR | gzip $COMPRESSION_LEVEL > $COMP_TAR
	rm "$TAR"
	clear
	echo "Gzip is done compressing"
fi

