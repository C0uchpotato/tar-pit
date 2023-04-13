
Usage
--
~/.config/tar-pit/backup.txt is designed to be a user modified file that holds all of the files (from the users perspective, starting in ~)

Please create this file if you do not want your entire home directory "tarred", otherwise the program will create this file and select all files under ~

An example will be hosted under example backup.txt

~/.config/tar-pit/conf will be created with sane defaults after the first run of this software, a copy will be hosted under default_conf.

**Warning:** If you run this program multiple times, it will overwrite the tar file from previous runs on that day, as each file is named according to the system date



Mission
--
The purpose of this program is to automatically create a backup (tar to begin with), of my home directory and important files, then split it to fit on 7.9 GB DVD's.

Dependencies
--
[Dmuth's tarsplit](https://github.com/dmuth/tarsplit)
This will be installed automatically using pip to the local profile

Bash

Python3

Return Values
--

0 or nothing    Program ran successfully

1   Program could not find a required directory, either create it or double check that you have write
privileges in .config and ~



Roadmap
--

**TODO: Add pacmanfile option**

**TODO: Create tar, run tarsplit, compress split tar file(s)**

**TODO: Verify chunk sizes**

**TODO: Auto burn to cd**

**TODO: Compress chunks after tarsplit**

**TODO: Create testing**

**TODO: Support external target locations**

**TODO: Add sha512 hashing for temp files**
