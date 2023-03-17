#!/bin/bash
DIR=~/.config/tar-pit
USER_CONFIG=~/.config/tar-pit/backup.txt
DEFAULT_CONFIG=~/.config/tar-pit/home_index.txt
CONVERSION=1000000000
TAR=~/tar-pit/out.tar
TARGET=~/tar-pit
#Establish config directory

if [ -d "$DIR" ] ; then
	echo "Configuration file exists"
else
	mkdir $DIR
fi

cd ~
#Look for user config file
ls -a ~ > $DEFAULT_CONFIG

if [ -e "$USER_CONFIG" ] ; then
  echo "User defined config exists"
else
  echo "No user defined config exists"
fi


echo "Configuration complete"
echo "home_index updated"
echo "installing tarsplit"

#Install tarsplit
python3 -m pip install tarsplit > /dev/null


#Read from either default or user config, then tar respective selections
cd ~/.config/tar-pit

if [ -e $USER_CONFIG ] ; then

  cd ~
  echo "User defined config found"
  echo "Making tar file, this may take a while"
  tar --zstd -cvhf out.tar --verbatim-files-from --files-from=$USER_CONFIG ##TODO: Progress bar

#need to use pv or some other method to create an ETA or progress bar

else
  echo "No modified config file found, defaulting to "tar"-ing entire home directory"
  cd ~
  echo "Making tar file, this may take a while"
  tar -cvzhf out.tar --files-from=$DEFAULT_CONFIG ##TODO: Progress bar
fi

#Setup target directory, and move resulting tar file
if [ -d $TARGET ] ; then
  echo "Target directory exists"
else
  mkdir $TARGET
fi

mv out.tar $TARGET
echo "tar file completed"
echo "out.tar moved to ~/tar-pit"


cd $TARGET

#Use du to dump size of Tar file
du -b $TAR > chunk_size.txt

#Use awk and bash to strip all non-numerical characters

TAR_SIZE=$(awk '{$1=$1;print}' chunk_size.txt)
TAR_SIZE=${TAR_SIZE//[^0-9]/}
rm chunk_size.txt


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
