import subprocess
import sys
import threading
import time
import yaml
import shutil
import os

def execute(cmd: str) -> str:
  try:
    return subprocess.check_output(cmd, shell=True).decode("utf-8")
  except subprocess.CalledProcessError as e:
    print(e.output)
    sys.exit(1)

def p(pre: str, name: str):
  print(f">> {pre} [{name}]")

def pretty_print(msg, color="\033[92m"):
    """Print message in pretty format
  Args:
      msg (string): message to print
  """
    # print message in pretty format colored green and bold with centered text and wrapped in = signs
    print(f"""
{color}{'=' * 74}
{msg.center(74)}
{'=' * 74}\033[0m
""")

def cp(src: str, dst: str):
  print(f">> Copying [{src}] to [{dst}]")
  # check if dir or file
  if os.path.isdir(src):
    if src.startswith("~"):
      src = os.path.expanduser(src)
    if dst.startswith("~"):
      dst = os.path.expanduser(dst)
    shutil.copytree(src, dst, dirs_exist_ok=True)
  else:
    shutil.copy(src, dst)

class PackageManager:
  def __init__(self, manager: str ="yay") -> None:
    self.manager = manager

  def check_package(self, package) -> bool:
      # check if error code then package is not installed
      try:
          execute(self.manager + " -Q " + package + " &> /dev/null")
          return True
      except:
          return False
  def install_package(self, package: str) -> None:
      if not self.check_package(package):
          p("Installing", package)
          execute(self.manager + " -S " + package +
                  " --noconfirm --needed --quiet")
      else:
          print(f">> {package} is already installed")
  
  def update_mirrorlist(self) -> None:
      execute(self.manager + " -Syy")
      execute(f"{self.manager} -Syu --noconfirm --quiet")
      execute(f"{self.manager} -S reflector --noconfirm --needed --quiet")
      execute("sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist")

class Installer:
  banner = """
==========================================================================
  ___           _    ______         ___  ___           _     _            
 / _ \         | |   | ___ \        |  \/  |          | |   (_)           
/ /_\ \_ __ ___| |__ | |_/ /__ _ __ | .  . | __ _  ___| |__  _ _ __   ___ 
|  _  | '__/ __| '_ \|  __/ _ \ '_ \| |\/| |/ _` |/ __| '_ \| | '_ \ / _ \\
| | | | | | (__| | | | | |  __/ | | | |  | | (_| | (__| | | | | | | |  __/
\_| |_/_|  \___|_| |_\_|  \___|_| |_\_|  |_/\__,_|\___|_| |_|_|_| |_|\___|
================================== Developed by: Drake Axelrod (draxel.io)
"""
  def __init__(self, config: str="config.yml") -> None:
    self.config = yaml.load(open(config), Loader=yaml.FullLoader)
    if "package_manager" in self.config:
      self.pm = PackageManager(self.config["package_manager"])
    else:
      self.pm = "pacman"

  def install_config(self, f) -> None:
    p("Configuring", f.__name__)
    f()

  def systemd(self):
    if "systemd" in self.config:
      if "enable" in self.config["systemd"]:
        for service in self.config["systemd_services"]:
            p("Enabling", service)
            execute("sudo systemctl enable " + service)
            p("Starting", service)
            execute("sudo systemctl start " + service)

  def scripts(self):
    if not os.path.exists(os.path.expanduser("~/.local")):
        os.mkdir(os.path.expanduser("~/.local"))
    if not os.path.exists(os.path.expanduser("~/.local/bin")):
        os.makedirs(os.path.expanduser("~/.local/bin"))
    for file in os.listdir("scripts"):
        cp(f"scripts/{file}", os.path.expanduser(f"~/.local/bin/{file}"))
        execute(f"chmod +x {os.path.expanduser(f'~/.local/bin/{file}')}")

  def autostart_programs(self):
    if "autostart_programs" in self.config:
      cp("configs/autostart", os.path.expanduser("~/.config/autostart"))

  def ulauncher(self):
    if self.pm.check_package("ulauncher"):
      cp("configs/ulauncher", os.path.expanduser("~/.config/ulauncher"))

  def git(self):
    if not os.path.exists(os.path.expanduser("~/.config/git")) and check_package("git"):
      # copy git directory to ~/.config/git except if git ignored
      cp("configs/git", os.path.expanduser("~/.config/git"))
    
      # check if config has git.email and git.name are empty strings
      if self.config["git"]["email"] == "" or self.config["git"]["name"] == "":
          print(">> git email and name not configured")
          # ask if user wants to provide git email and name in red
          print("\033[91m>> do you want to provide git email and name? [y/n]\033[0m", end=" ")
          ans = input().lower()
          if ans == "y":
              # ask for git email and name
              print(">> enter git email", end=": ")
              email = input()
              print(">> enter git name", end=": ")
              name = input()
              # set git email and name
              execute(f"git config --global user.email {email}")
              execute(f"git config --global user.name {name}")
      else:
        # set git email and name
        execute("git config --global user.email " + self.config["git"]["email"])
        execute("git config --global user.name " + self.config["git"]["name"])

  def zsh(self):
    # install zplug
    if self.pm.check_package("zsh"):
      os.environ["ZDOTDIR"] = os.path.expanduser("~/.config/zsh")
      os.environ["ZPLUG_HOME"] = os.path.expanduser("~/.config/zsh/zplug")
      # zsh libs
      execute("zsh ./installers/zsh.sh")
      if os.environ["SHELL"] != "/bin/zsh":
          execute("chsh -s /bin/zsh")
      cp("configs/zshenv", os.path.expanduser("~/.zshenv"))
      cp("configs/zsh", os.path.expanduser("~/.config/zsh"))

  def kitty(self):
      """Configure kitty"""
      if self.pm.check_package("kitty"):
        cp("configs/kitty", os.path.expanduser("~/.config/kitty"))

  def lunarvim(self):
    if self.pm.check_package("neovim"):
      # set environment variable
      os.environ["LV_BRANCH"] = "rolling"
      # install lunarvim
      execute("LV_BRANCH=rolling bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/rolling/utils/installer/install.sh) -y --install-dependencies")
      # copy lunarvim directory to ~/.config/lunarvim except if git ignored
      cp("configs/lvim", os.path.expanduser("~/.config/lvim"))

  def rust(self):
    os.environ["CARGO_HOME"] = os.path.expanduser("~/.local/share/cargo")
    os.environ["RUSTUP_HOME"] = os.path.expanduser("~/.local/share/rustup")
    # set rustup to stable
    os.system("rustup default stable")
    if os.path.exists(os.path.expanduser("~/.rustup")):
        shutil.rmtree(os.path.expanduser("~/.rustup"))
    if os.path.exists(os.path.expanduser("~/.cargo")):
        shutil.rmtree(os.path.expanduser("~/.cargo"))

  def gnupg(self):
    cp("configs/gnupg", os.path.expanduser("~/.local/share/gnupg"))

  def haskell(self):
    """Configure haskell"""
    cp("configs/cabal", os.path.expanduser("~/.config/cabal"))
    cp("configs/stack", os.path.expanduser("~/.config/stack"))

  def kde_settings(self):
    # /home/test/.local/share/plasma/look-and-feel
    # extract ./Utterly-Nord.tar.xz to ~/.local/share/plasma/look-and-feel
    execute("tar -xf ./Utterly-Nord.tar.xz -C ~/.local/share/plasma/look-and-feel")
    # extract ./oreo-spark-red-cursor.tar.gz to ~/.local/share/icons
    if not os.path.exists(os.path.expanduser("~/.local/share/icons")):
        os.makedirs(os.path.expanduser("~/.local/share/icons"))
    # extract oreo-spark-red-cursors.tar.gz to ~/.local/share/icons
    execute("tar -xf ./oreo-spark-red-cursors.tar.gz -C ~/.local/share/icons")
    # copy kglobalshortcutsrc to ~/.config/kglobalshortcutsrc, kdeglobals to ~/.config/kdeglobals, khotkeysrc to ~/.config/khotkeysrc
    cp("configs/kglobalshortcutsrc", os.path.expanduser("~/.config/kglobalshortcutsrc"))
    # copy kdeglobals to ~/.config/kdeglobals
    cp("configs/kdeglobals", os.path.expanduser("~/.config/kdeglobals"))
    # copy khotkeysrc to ~/.config/khotkeysrc
    cp("configs/khotkeysrc", os.path.expanduser("~/.config/khotkeysrc"))
    cp("configs/kdedefaults", os.path.expanduser("~/.config/kdedefaults"))

  def docs(self):
    # git clone --recursive https://github.com/jekil/awesome-hacking.git into ~/Documents/resources
    # if not os.path.exists(os.path.expanduser("~/Documents/resources")):
    #     os.makedirs(os.path.expanduser("~/Documents/resources"))
    # execute("git clone --recursive https://github.com/jekil/awesome-hacking.git ~/Documents/resources/awesome-hacking")
    # # https://github.com/blaCCkHatHacEEkr/PENTESTING-BIBLE.git into ~/Documents/resources
    # execute("git clone https://github.com/blaCCkHatHacEEkr/PENTESTING-BIBLE.git ~/Documents/resources/PENTESTING-BIBLE")
    # # https://github.com/sundowndev/hacker-roadmap into ~/Documents/resources
    # execute("git clone https://github.com/sundowndev/hacker-roadmap ~/Documents/resources/hacker-roadmap")

    # # cp all files and directories in ./Documents to ~/Documents/resources
    # for file in os.listdir("documents"):
    #     if os.path.isdir("documents/" + file):
    #         shutil.copytree("documents/" + file, os.path.expanduser("~/Documents/resources/" + file))
    #     else:
    #         shutil.copyfile("documents/" + file, os.path.expanduser("~/Documents/resources/" + file))
    pass

  def repo_tools(self):
    # mkdir ~/tools
    if not os.path.exists(os.path.expanduser("~/tools")):
      os.makedirs(os.path.expanduser("~/tools"))
    """ nuclei """
    print(">> Installing [nuclei]")
    execute("go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest")
    """ gospider """
    print(">> Installing [gospider]")
    execute("GO111MODULE=on go install github.com/jaeles-project/gospider@latest")
    """ sandmap """
    # https://github.com/trimstray/sandmap
    if not os.path.exists(os.path.expanduser("~/tools/sandmap")):
      print(">> Installing [sandmap]")
      execute("git clone --recursive https://github.com/trimstray/sandmap ~/tools/sandmap")
      execute("cd ~/tools/sandmap && ./setup.sh install")

  # run all installer scripts]
  def install_configs(self):
    # get all class methods
    funcs = [func for func in dir(self) if callable(getattr(self, func)) and not func.startswith("__")]
    # remove install_configs install_packages
    funcs.remove("install_configs")
    funcs.remove("install_packages")
    funcs.remove("install_config")
    # run all methods with install_config
    for func in funcs:
      self.install_config(getattr(self, func))

  def install_packages(self, key: str):
      if "packages" in self.config:
        if key in self.config["packages"]:
          p("Installing", key)
          for package in self.config["packages"][key]:
            self.pm.install_package(package)

def main():
  i = Installer()
  # start
  print(i.banner)
  # check if command line arguments for config file is provided
  if len(sys.argv) > 1:
      if os.path.exists(sys.argv[1]):
          print(f">> using config file [{sys.argv[1]}]")
          i.config = yaml.load(open(sys.argv[1]), Loader=yaml.FullLoader)
  else:
      print("\033[91mconfig file not provided using default\033[0m")

  if i.config["update_mirrorlist"]:
    print("\033[91m" + "do you want to update system and mirrors? [y/n]" + "\033[0m", end=" ")
    ans = input().lower()
    if ans == "y" or ans == "yes":
      i.pm.update_mirrorlist()
    else:
      print(">> skipping mirrorlist update")

  i.install_packages("general")
  i.install_configs()
  i.install_packages("pentest_tools")

if __name__ == "__main__":
  main()
