#!/bin/bash

echo "Thank you for your time, uninstalling tar-pit from /usr/local/bin"

sudo rm /usr/local/bin/tar-pit.sh

echo "Tarsplit will remain installed under the current user profile"
echo "You can remove tarsplit by running:"
echo "pip uninstall tarsplit"
