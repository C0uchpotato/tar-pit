Usage
--
~/.config/backup.txt is designed to be a user modified file that holds all of the files (from the users perspective, starting in ~)

Please create this file if you do not want your entire home directory "tarred", otherwise the program will create this file and select all files under ~

An example will be hosted under example backup.txt

This script (as of now) has no flags, and takes no input from the user while running



Mission
--
This program is designed with my own needs in mind and may not fit every system, although I plan to build it with the flexibility needed to adjust easily.

The purpose of this program is to automatically create a backup (tar to begin with), of my home directory and important files, then split it to fit on 7.9 GB DVD's.

Dependencies
--
[Dmuth's tarsplit](https://github.com/dmuth/tarsplit)
This will be installed automatically using pip to the local profile


Roadmap
--
##TODO: Verify chunk sizes##

##TODO: Auto burn to cd##

##TODO: Make a progress bar for tar process##
