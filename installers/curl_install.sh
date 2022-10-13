#! /usr/bin/env sh



cd /tmp
git clone https://github.com/DrakeAxelrod/ArchPenMachineStrapper.git
cd ArchPenMachineStrapper

# git python bin
PYBIN=$(which python)

if [ -f "$1" ]; then
    # get the full path to the file
    FILE=$(readlink -f "$1")
    # run install.py with python with the first argument as the path to the config file
    $PYBIN ./install.py "$FILE"
else
    # run install.py with python
    $PYBIN ./install.py
fi
unset PYBIN
