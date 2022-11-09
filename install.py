import subprocess
import sys
import yaml
import shutil
import os

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

# ======================== Utils ======================== #


def read_config() -> dict:
    """Load the config.yml

  Returns:
      dict: configurations
  """
    # open config.yml
    return yaml.load(open("config.yml"), Loader=yaml.FullLoader)


def execute(cmd) -> str:
    """Execute system commands and return output

  Args:
      cmd (string): command to execute

  Returns:
      str: output of command
  """
    return subprocess.check_output(cmd, shell=True).decode("utf-8")


def check_package(package) -> bool:
    """Check if package is installed

  Args:
      package (string): package to check

  Returns:
      bool: if package is installed
  """
    global config
    # check if error code then package is not installed
    try:
        execute(config["package_manager"] + " -Q " + package + " &> /dev/null")
        return True
    except:
        return False


def install_package(package) -> None:
    """Install package if not installed

  Args:
      package (string): package to install
  """
    global config
    if not check_package(package):
        print(f">> installing [{package}]")
        execute(config["package_manager"] + " -S " + package +
                " --noconfirm --needed --quiet")
    else:
        print(package + " is already installed")


def cp_config_dir(directory) -> None:
    """Copy directory from configs to .config

  Args:
      directory (string): directory to copy
  """
    # copy directory to ~/.config/directory except if git ignored
    shutil.copytree(f"configs/{directory}",
                    os.path.expanduser("~/.config/" + directory),
                    dirs_exist_ok=True)


def update_mirrorlist():
    """Update system and install reflector if not installed and update mirrors"""
    global config

    execute(config["package_manager"] + " -Syu --noconfirm --quiet")
    execute(config["package_manager"] +
            " -S reflector --noconfirm --needed --quiet")
    execute(
        "sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist"
    )


# ======================== Configs ======================== #
def config_wrapper(func):
    """Configure wrapper"""
    print(f">> configuring [{func.__name__}]")
    func()


def systemd():
    """Configure systemd"""
    global config
    # enable systemd services
    # check if config has key systemd
    if "systemd" in config:
      if "enable" in config["systemd"]:
        for service in config["systemd_services"]:
            print(f">> configuring service [{service}]")
            execute("sudo systemctl enable " + service)
            execute("sudo systemctl start " + service)

def scripts():
    """Configure scripts"""
    if not os.path.exists(os.path.expanduser("~/.local")):
        os.mkdir(os.path.expanduser("~/.local"))
    if not os.path.exists(os.path.expanduser("~/.local/bin")):
        os.makedirs(os.path.expanduser("~/.local/bin"))
    # copy all files in scripts to ~/.local/bin
    for file in os.listdir("scripts"):
        shutil.copy(f"scripts/{file}", os.path.expanduser("~/.local/bin"))
    execute("chmod +x ~/.local/bin/*")

def autostart_programs():
    # copy autostart directory to ~/.config/autostart except if git ignored
    cp_config_dir("autostart")


# configure ulauncher
def ulauncher():
  if check_package("ulauncher"):
    # copy config directories
    cp_config_dir("ulauncher")


# configure git
def git():
    """Configure git"""
    # check if .config/git/config exists
    if not os.path.exists(os.path.expanduser("~/.config/git")) and check_package("git"):
      # copy git directory to ~/.config/git except if git ignored
      cp_config_dir("git")
    
      # check if config has git.email and git.name are empty strings
      if config["git"]["email"] == "" or config["git"]["name"] == "":
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
        execute("git config --global user.email " + config["git"]["email"])
        execute("git config --global user.name " + config["git"]["name"])


# zsh
def zsh():
    """Configuring zsh"""
    # install zplug
    if check_package("zsh"):
      os.environ["ZDOTDIR"] = os.path.expanduser("~/.config/zsh")
      os.environ["ZPLUG_HOME"] = os.path.expanduser("~/.config/zsh/zplug")
      # zsh libs
      execute("zsh ./installers/zsh.sh")
      # copy .zshenv to home directory and overwrite if exists
      # change default shell redirect password to stdin if zsh is not default shell
      if os.environ["SHELL"] != "/bin/zsh":
          execute("chsh -s /bin/zsh")
      shutil.copyfile("configs/zshenv", os.path.expanduser("~/.zshenv"))
      cp_config_dir("zsh")


def kitty():
    """Configure kitty"""
    if check_package("kitty"):
    # copy kitty directory to ~/.config/kitty except if git ignored
      cp_config_dir("kitty")


# lunarvim
def lunarvim():
    """Configure lunarvim"""
    if check_package("neovim"):
      # set environment variable
      os.environ["LV_BRANCH"] = "rolling"
      # install lunarvim
      execute("LV_BRANCH=rolling bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/rolling/utils/installer/install.sh) -y --install-dependencies")
      # copy lunarvim directory to ~/.config/lunarvim except if git ignored
      cp_config_dir("lvim")


# install and configure cargo
def rust():
    """Configure rustup"""
    os.environ["CARGO_HOME"] = os.path.expanduser("~/.local/share/cargo")
    os.environ["RUSTUP_HOME"] = os.path.expanduser("~/.local/share/rustup")
    # set rustup to stable
    os.system("rustup default stable")
    if os.path.exists(os.path.expanduser("~/.rustup")):
        shutil.rmtree(os.path.expanduser("~/.rustup"))
    if os.path.exists(os.path.expanduser("~/.cargo")):
        shutil.rmtree(os.path.expanduser("~/.cargo"))

def gnupg():
    """Configure gnupg"""
    # copy gnupg directory to ~/.config/gnupg except if git ignored
    cp_config_dir("gnupg")

def haskell():
    """Configure haskell"""
    # copy haskell directory to ~/.config/haskell except if git ignored
    cp_config_dir("cabal")

def kde_settings():
    """Configure kde settings"""
    # /home/test/.local/share/plasma/look-and-feel
    # extract ./Utterly-Nord.tar.xz to ~/.local/share/plasma/look-and-feel
    execute("tar -xf ./Utterly-Nord.tar.xz -C ~/.local/share/plasma/look-and-feel")
    # extract ./oreo-spark-red-cursor.tar.gz to ~/.local/share/icons
    if not os.path.exists(os.path.expanduser("~/.local/share/icons")):
        os.makedirs(os.path.expanduser("~/.local/share/icons"))
    execute("tar -xf ./oreo-spark-red-cursor.tar.gz -C ~/.local/share/icons")
    # copy kglobalshortcutsrc to ~/.config/kglobalshortcutsrc, kdeglobals to ~/.config/kdeglobals, khotkeysrc to ~/.config/khotkeysrc
    shutil.copyfile("configs/kglobalshortcutsrc", os.path.expanduser("~/.config/kglobalshortcutsrc"))
    # copy kdeglobals to ~/.config/kdeglobals
    shutil.copyfile("configs/kdeglobals", os.path.expanduser("~/.config/kdeglobals"))
    # copy khotkeysrc to ~/.config/khotkeysrc
    shutil.copyfile("configs/khotkeysrc", os.path.expanduser("~/.config/khotkeysrc"))
    cp_config_dir("kdedefaults")



# ======================== Main ======================== #
      

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


if __name__ == "__main__":
    global config
    # start
    print("\033[96m" + banner + "\033[0m")
    # check if command line arguments for config file is provided
    if len(sys.argv) > 1:
        print(">> using config file: " + sys.argv[1])
        # check if config file exists
        if os.path.exists(sys.argv[1]):
            # read config file
            print(">> reading custom config file")
            config = yaml.load(open(sys.argv[1]), Loader=yaml.FullLoader)
    else:
        # print error message and exit
        print("\033[91mconfig file not provided using default\033[0m")
        print()
        config = read_config()

    # print(config)

    # update system and mirrorlist
    # pretty_print(
    #     "Performing system update and mirrorlist update please do not exit",
    #     "\033[91m")
    # ask if user wants to update system and mirrors
    if "update_mirrorlist" in config and config["update_mirrorlist"]:
        print(">> updating mirrorlist")
        update_mirrorlist()
    else:
      print("\033[91m" + "do you want to update system and mirrors? [y/n]" + "\033[0m", end=" ")
      ans = input().lower()
      if ans == "y" or ans == "yes":
        update_mirrorlist()
      else:
        print(">> skipping update")

    # install packages green
    if "packages" in config:
      if "general" in config["packages"]:
        pretty_print("Installing general packages")
        for package in config["packages"]["general"]:
            install_package(package)

    # configuring system

    pretty_print("Configuring system")
    systemd()

    for func in [scripts, git, gnupg, zsh, rust, autostart_programs, ulauncher, lunarvim, kitty, kde_settings, haskell]:
        config_wrapper(func)

    # install pentest tools
    if "packages" in config and config["pentest_setup"] == True:
      if "pentest_tools" in config["packages"]:
        pretty_print("Installing pentest tools")
        for package in config["packages"]["pentest_tools"]:
            install_package(package)
