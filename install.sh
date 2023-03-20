#!/bin/bash

echo "Thank you for installing tar-pit!"
echo "copying tar-put to /usr/local/bin"
##TODO: Add actual install scripts
sudo cp tar-pit.sh /usr/local/bin

echo "installing tarsplit"
python3 -m pip install tarsplit > /dev/null
