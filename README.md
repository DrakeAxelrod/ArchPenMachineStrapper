
# Archlinux Pentest Bootstrapper

## Dependencies

- yay or paru
- git
- python3 (yaml, shutil, os, subprocess)

## configuration

to change configurations modify config.yml


## install

set your git email and user name in config.yml and decide which packages you want to install and which configs you want to use

```bash
# this will use the default config.yml
bash <(curl -s https://raw.githubusercontent.com/DrakeAxelrod/ArchPenMachineStrapper/main/installers/curl_install.sh)
```

OR

```bash
git clone https://github.com/DrakeAxelrod/ArchPenMachineStrapper.git
cd ArchPenMachineStrapper
# from root of project
python install.py
```

## Notes

change the git config file to use your username and email :D
