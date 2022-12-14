
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

you can provide a custom config file with the curl command

format
```yml
package_manager: yay # or "paru"
git:
  user: ""
  email: ""
systemd_services:
  - vmtoolsd # VMware Tools
  - vmware-vmblock-fuse # VMware Tools
  - docker # Docker
packages:
  general:
    - ulauncher # Ulauncher
    - imwheel # Mouse wheel acceleration
    - openvpn # VPN
    - keybase-bin # Keybase
    - open-vm-tools # VMware Tools
    - nerd-fonts-jetbrains-mono # Nerd Fonts
    - git # Git
    - zsh # Terminal shell (Zsh)
    - kitty # Terminal emulator (Kitty)
    - neovim # Text editor (Neovim)
    - bat # Cat clone with syntax highlighting and Git integration
    - ripgrep # Line-oriented search tool that recursively searches your current directory for a regex pattern
    - fd # Simple, fast and user-friendly alternative to find
    - lsd # The next gen ls command (ls replacement)
    - grc # Colourize logfiles and command output
    - ncdu # Disk usage analyzer with an ncurses interface
    - papirus-icon-theme # Papirus icon theme
    - thefuck # Magnificent app which corrects your previous console command
    - rustup # Rust toolchain installer
    - visual-studio-code-bin # Visual Studio Code
    - docker # Docker
    - texlive-core # TeX Live
    - latex-mk # LaTeX build tool
    - flameshot # Screenshot tool
  pentest_tools:
    - nmap # Network exploration tool and security / port scanner
    - vulscan # Nmap NSE script for vulnerability scanning
    - metasploit # Penetration testing framework
    - wordlists # Wordlists for password cracking and other security testing
    - burpsuite # Web application security testing tool
    - burpsuite-pro # Burp Suite Professional
    - sqlmap # Automatic SQL injection and database takeover tool
    - gobuster # Directory/file, DNS and virtual host busting tool written in Go
    - dirb # Web Content Scanner
    - dirbuster # Web Content Scanner
    - nikto # Web server scanner which performs comprehensive tests against web servers for multiple items, including over 6700 potentially dangerous files/programs
    - nessus # Vulnerability scanner
    - wpscan # WordPress vulnerability scanner
    - wireshark-qt # Network protocol analyzer
    - wireshark-cli # Network protocol analyzer
    - tcpdump # Network traffic analyzer
    - john # Password cracker
    - gnu-netcat # Networking utility which reads and writes data across networks from the command line
    - inetutils # Collection of common network programs
    - net-tools # Collection of common network tools
    - traceroute # Traces the route taken by packets over an IP network
    - iputils # Collection of small useful utilities for Linux networking
    - nessus # Vulnerability scanner
```

command
```bash
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
