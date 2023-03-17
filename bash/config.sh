#!/bin/bash
DIR=~/.config/tar-pit
USER_CONFIG=~/.config/tar-pit/backup.txt
DEFAULT_CONFIG=~/.config/tar-pit/home_index.txt

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
