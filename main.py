#!/usr/bin/python3
import subprocess

#check for config files, if not present make the directory and file
#dump all home folders and files to home_index in config directory
subprocess.call(['sh', './bash/config.sh'])

#Check for user config file, then either tar selected directories or entire /home
#When finished, moves out.tar to ~/Archive
subprocess.call(['sh', './bash/tar.sh'])

#split tar into chunks < 7.9 GB, then clean and exit
subprocess.call(['sh', './bash/post-tar.sh'])
