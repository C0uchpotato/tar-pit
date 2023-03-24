#!/bin/bash

echo "Thank you for installing tar-pit!"
echo "copying tar-pit to /usr/local/bin"
##TODO: Add actual install scripts
sudo cp tar-pit.sh /usr/local/bin

echo "installing tarsplit"
pip install -r requirements.txt > /dev/null
