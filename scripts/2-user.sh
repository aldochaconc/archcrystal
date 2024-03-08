#!/usr/bin/env bash

source $HOME/archcrystal/setup.conf
export PATH=$PATH:~/.local/bin

if ! command -v yay &>/dev/null; then
  echo "Installing AUR Helper"
  cd ~ && git clone "https://aur.archlinux.org/yay.git" && cd ~/yay && makepkg -si --noconfirm && cd ~
else
  echo "yay is already installed"
fi
yay -Sc --noconfirm

installPackages() {
  declare -n packages=$1
  local toInstallPacman=""
  local toInstallYay=""

  echo "Packages to install"
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

echo "Installing essentials"
declare -A essentials=(
  # Basic dependencies
  ["yay:mkinitcpio-firmware"]="Firmware and drivers for initramfs"
  ["pacman:libsecret"]="Allow apps use gnome-keyring"
  ["pacman:xsel"]="Clipboard manager"

  # Terminal
  ["pacman:rxvt-unicode"]="terminal emulator"
  ["pacman:urxvt-perls"]="Perl extensions for urxvt"
  ["pacman:zsh"]="shell"

  # Monitor
  ["pacman:acpid"]="DAEMON to dispatch ACPI events"
  ["pacman:htop"]="CLI process administrator"
  ["pacman:thermald"]="DAEMON to prevent cpu overheating"
  ["pacman:ufw"]="DAEMON Firewall"
  ["pacman:neofetch"]="CLI System information tool"

  # Graphic server
  ["pacman:xorg-xinit"]="Xinit"
  ["pacman:xorg"]="Xorg"
)
installPackages essentials

echo "Setting up ZSH as default shell"
chsh -s /bin/zsh
echo "Installing oh-my-zsh"
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Enabling services"
sudo systemctl enable acpid
sudo systemctl enable thermald
sudo systemctl enable ufw
sudo ufw enable

echo "Installing audio drivers"
declare -A drivers=(
  # Audio
  ["pacman:pipewire"]="Audio server"
  ["pacman:pipewire-audio"]="Audio server"
  ["pacman:pipewire-docs"]="Pipewire documentation"
  ["pacman:wireplumber"]="Pipewire session manager"
  ["pacman:pipewire-alsa"]="Pipewire alsa"
  # Bluetooth
  ["pacman:bluez"]="Bluetooth stack"
  ["pacman:bluez-utils"]="Bluetooth stack"
  # Printer
  ["pacman:cups"]="Printer"
)
installPackages drivers

echo "Enabling drivers"
sudo systemctl enable cups
sudo systemctl enable bluetooth

echo "Installing desktop apps"
declare -A desktopApps=(
  # wm
  ["pacman:i3"]="Tiling manager"
  ["pacman:i3status"]="i3 bar"

  # Ricing
  ["pacman:dunst"]="DAEMON Notification server"
  ["pacman:feh"]="Image viewer and wallpaper setter"
  ["pacman:picom"]="Compositor"
  ["pacman:rofi"]="App launcher"

  # apps
  ["pacman:autorandr"]="Autorefresh screen layouts"
  ["pacman:chromium"]="A web browser built for speed, simplicity, and security"
  ["pacman:discord"]="All-in-one voice and text chat"
  ["pacman:ncdu"]="disk usage cli"
  ["pacman:p7zip"]="Compression tool"
  ["pacman:powerline"]="Statusline plugin for vim"
  ["pacman:redshift"]="Image viewer"
  ["pacman:tree"]="Show directory structures in cli"
  ["pacman:xdg-user-dirs"]="Setup default dirs"

  # gnome env
  ["pacman:arandr"]="GNOME Screen layout manager"
  ["pacman:gnome-keyring"]="GNOME Keyring for psw management"
  ["pacman:gnome-screenshot"]="GNOME Screenshots app"
  ["pacman:gparted"]="GNOME Disk manager"
  ["pacman:nautilus"]="GNOME File explorer"
  ["pacman:pavucontrol"]="GNOME Volume Control"
  ["pacman:polkit-gnome"]="GNOME auth agent (dependency for gui apps)"
  ["pacman:seahorse"]="GNOME application for managing PGP keys"
  ["pacman:seahorse-nautilus"]="GNOME application for managing PGP keys"
)
installPackages desktopApps
xdg-user-dirs-update

echo "Installing fonts"
declare -A fonts=(
  ["pacman:adobe-source-han-sans-otc-fonts"]="Adobe fonts for CN, KR, JP compat"
  ["pacman:ttf-fira-code"]="Base font"
  ["pacman:ttf-font-awesome"]="Dependency for powerline"
  ["yay:powerline-fonts-git"]="Fonts for the powerline statusline plugin"
  ["yay:ttf-font-icons"]="A set of icons and symbols for TTF fonts"
  ["yay:ttf-ionics"]="A set of icons and symbols for TTF fonts"
  ["yay:ttf-roboto-mono"]="Monospaced font family for user interface and coding environments"
)
installPackages fonts

# declare -A dev=(
#   ["pacman:docker"]="Container runtime"
#   ["pacman:docker-compose"]="Container runtime"
#   ["pacman:go"]="Go"
#   ["yay:nvm"]="Node version manager"
#   ["pacman:python-pip"]="The PyPA recommended tool for installing Python packages"
#   ["pacman:python-psutil"]="Required by a lot of packages"
# )

echo "SYSTEM READY FOR 3-post-setup.sh"
read -p "Press enter to continue"
exit
