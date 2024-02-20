#!/usr/bin/env bash
#github-action genshdoc
#
# @file User
# @brief User customizations and AUR package installation.

source $HOME/archcrystal/setup.conf
export PATH=$PATH:~/.local/bin

if ! command -v yay &>/dev/null; then
  echo -ne "
Installing AUR Helper
"
  cd ~ && git clone "https://aur.archlinux.org/yay.git" && cd ~/yay && makepkg -si --noconfirm
  cd ~
else
  echo "yay is already installed"
fi
yay -Sc --noconfirm

installPackages() {
  declare -n packages=$1
  local toInstallPacman=""
  local toInstallYay=""

  for key in "${!packages[@]}"; do
    local packageManager=${key%%:*}
    local package=${key#*:}
    echo "- $package: ${packages[$key]}"
    if [ "$packageManager" = "pacman" ]; then
      toInstallPacman+="$package "
    elif [ "$packageManager" = "yay" ]; then
      toInstallYay+="$package "
    fi
  done

  # clears pacman cache

  read -p "Press enter to continue"

  if [ -n "$toInstallPacman" ]; then
    sudo pacman -S --noconfirm $toInstallPacman
  fi
  sudo paccache -r
  if [ -n "$toInstallYay" ]; then
    yay -S --noconfirm $toInstallYay
  fi
  yay -Sc --noconfirm
}

declare -A pkgsToInstall=(
  # Essentials
  ["pacman:git"]="versioning"
  ["pacman:python-pip"]="The PyPA recommended tool for installing Python packages"
  ["pacman:python-psutil"]="Required by a lot of packages"
  ["pacman:vim"]="Vim"
  ["pacman:libsecret"]="Allow apps use gnome-keyring"
  ["pacman:ufw"]="DAEMON Firewall"
  ["pacman:pacman-contrib"]="Contributed scripts and tools for pacman systems"

  # Environment
  ["pacman:nodejs"]="Node.js"
  ["pacman:rxvt-unicode"]="terminal emulator"
  ["pacman:zsh"]="shell"
  ["yay:nvm"]="Node version manager"

  # Monitoring
  ["pacman:acpid"]="DAEMON to dispatch ACPI events"
  ["pacman:htop"]="CLI process administrator"
  ["pacman:ncdu"]="disk usage cli"
  ["pacman:neofetch"]="i use arch btw"
  ["pacman:thermald"]="DAEMON to prevent cpu overheating"

  # Network
  ["pacman:ntp"]="Network Time Protocol"
  ["pacman:bluez-utils"]="Utilities such as bluetoothctl"

  # Compatibility
  ["pacman:dosfstools"]="DOS filesystem utilities"
  ["pacman:ifuse"]="A fuse filesystem to access the contents of iOS devices"
  ["pacman:libimobiledevice"]="A cross-platform librariesand tools for iOS"
  ["pacman:ntfs-3g"]="NTFS filesystem driver and utilities (windows compat)"
  ["pacman:os-prober"]="For detecting other operative system such as Windows"
  ["pacman:cups"]="Printers compat"

  # Fonts
  ["pacman:adobe-source-han-sans-otc-fonts"]="Adobe fonts for CN, KR, JP compat"
  ["pacman:ttf-font-awesome"]="Dependency for powerline"
  ["yay:powerline-fonts-git"]="Fonts for the powerline statusline plugin"
  ["yay:ttf-font-icons"]="A set of icons and symbols for TTF fonts"
  ["yay:ttf-roboto-mono"]="Monospaced font family for user interface and coding environments"

  # Desktop environment
  ["pacman:dunst"]="DAEMON Notification server "
  ["pacman:rofi"]="App launcher"
  ["pacman:i3"]="Tiling manager"
  ["pacman:i3status"]="i3 dependency (bar)"
  ["pacman:xdg-user-dirs"]="Setup default dirs"

  # Desktop Application (Prioritizing GNOME apps)
  ["pacman:arandr"]="GNOME Screen layout manager"
  ["pacman:autorandr"]="Autorefresh screen layouts"
  ["pacman:gnome-keyring"]="GNOME Keyring for psw management"
  ["pacman:gparted"]="GNOME Disk manager"
  ["pacman:nautilus"]="GNOME File explorer"
  ["pacman:pavucontrol"]="GNOME Volume Control"
  ["pacman:polkit-gnome"]="GNOME auth agent (dependency for gui apps)"
  ["pacman:seahorse"]="GNOME application for managing PGP keys"
  ["yay:lightscreen"]="GNOME Screenshots app"

  # Apps & Utilities
  ["pacman:chromium"]="A web browser built for speed, simplicity, and security"
  ["pacman:discord"]="All-in-one voice and text chat"
  ["pacman:p7zip"]="Compression tool"
  ["pacman:powerline"]="Statusline plugin for vim"
  ["pacman:tree"]="Show directory structures in cli"

  # Developer environment

)
installPackages pkgsToInstall

echo "Setting up ZSH as default shell"
chsh -s /bin/zsh
echo "Installing oh-my-zsh"
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Enabling services"
sudo systemctl enable acpid
sudo systemctl enable bluetooth
sudo systemctl enable cups
sudo systemctl enable NetworkManager
sudo systemctl enable ntpd
sudo systemctl enable thermald
sudo systemctl enable ufw
sudo systemctl enable paccache.timer
sudo systemctl enable trim.timer

echo "Setting up ZSH as default shell"
chsh -s /bin/zsh
echo "Installing oh-my-zsh"
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Setting up user directories"
xdg-user-dirs-update

echo "Setting up NVM"
mkdir -p ~/.nvm
echo "export NVM_DIR=\"$HOME/.nvm\"" >>$HOME/.zshrc
echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"  # This loads nvm" >>$HOME/.zshrc
echo "[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\"  # This loads nvm bash_completion" >>$HOME/.zshrc

echo "Setting up git"
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_NAME"

echo "Setting up firewall"
sudo ufw default deny
sudo ufw enable

echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-------------------------------------------------------------------------
"
read -p "Press enter to continue"
exit
