#! /usr/bin/env sh

cd /tmp
git clone https://github.com/DrakeAxelrod/ArchPenMachineStrapper.git
cd ArchPenMachineStrapper

# git python bin
PYBIN=$(which python)

# run install.py with python
$PYBIN ./install.py

unset PYBIN
