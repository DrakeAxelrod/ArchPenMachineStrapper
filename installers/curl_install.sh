#! /usr/bin/env sh



cd /tmp
git clone https://github.com/DrakeAxelrod/ArchPenMachineStrapper.git
cd ArchPenMachineStrapper

# git python bin
PYBIN=$(which python)

if [ -f "$1" ]; then
    # run install.py with python with the first argument as the path to the config file
    $PYBIN ./install.py "$1"
else
    # run install.py with python
    $PYBIN ./install.py
fi
unset PYBIN
