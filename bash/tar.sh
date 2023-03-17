#!/bin/bash
DEFAULT_CONFIG=~/.config/tar-pit/home_index.txt
USER_CONFIG=~/.config/tar-pit/backup.txt

#Read from either default or user config, then tar respective selections
cd ~/.config/tar-pit
echo "Making tar file, this may take a while"

if [ -e $USER_CONFIG ] ; then

  cd ~
  echo "User defined config found"
  tar -cvhf out.tar --verbatim-files-from --files-from=$USER_CONFIG >> /dev/null

else
  echo "No modified config file found, defaulting to "tar"-ing entire home directory"
  cd ~
  tar -cvhf out.tar --files-from=$DEFAULT_CONFIG
fi

#Setup target directory, and move resulting tar file
if [ -d ~/Archive ] ; then
  echo "Archive directory exists"
else
  mkdir ~/Archive
fi

mv out.tar ~/Archive
echo "tar file completed"
echo "out.tar moved to ~/Archive"
