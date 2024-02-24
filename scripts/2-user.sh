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

################################################################################

echo "Setup terminal"
declare -A terminal=(
  ["pacman:rxvt-unicode"]="terminal emulator"
  ["pacman:zsh"]="shell"
)
installPackages terminal
echo "Setting up ZSH as default shell"
chsh -s /bin/zsh
echo "Installing oh-my-zsh"
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

################################################################################
echo "Installing essentials"
declare -A essentials=(
  ["pacman:libsecret"]="Allow apps use gnome-keyring"
  ["pacman:ufw"]="DAEMON Firewall"
  ["yay:mkinitcpio-firmware"]="Firmware and drivers for initramfs"
)
installPackages essentials
echo "Setting up firewall"
sudo systemctl enable ufw
sudo ufw default deny
sudo ufw enable

###############################################################################
echo "Setting basic monitoring tools"
declare -A monitoring=(
  ["pacman:acpid"]="DAEMON to dispatch ACPI events"
  ["pacman:htop"]="CLI process administrator"
  ["pacman:thermald"]="DAEMON to prevent cpu overheating"
)
installPackages monitoring
sudo systemctl enable acpid
sudo systemctl enable thermald

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

declare -A graphicServer=(
  ["pacman:xorg"]="Xorg"
  ["pacman:i3"]="Tiling manager"
  ["pacman:i3status"]="i3 dependency (bar)"
  ["pacman:rofi"]="App launcher"
  ["pacman:dunst"]="DAEMON Notification server"
)
installPackages wm

echo "Installing desktop apps"
declare -A desktopApps=(
  ["pacman:feh"]="Image viewer"
  ["pacman:arandr"]="GNOME Screen layout manager"
  ["pacman:autorandr"]="Autorefresh screen layouts"
  ["pacman:gnome-keyring"]="GNOME Keyring for psw management"
  ["pacman:gparted"]="GNOME Disk manager"
  ["pacman:nautilus"]="GNOME File explorer"
  ["pacman:pavucontrol"]="GNOME Volume Control"
  ["pacman:polkit-gnome"]="GNOME auth agent (dependency for gui apps)"
  ["pacman:seahorse"]="GNOME application for managing PGP keys"
  ["pacman:gnome-screenshot"]="GNOME Screenshots app"
  ["pacman:xdg-user-dirs"]="Setup default dirs"
  ["pacman:ncdu"]="disk usage cli"

)
installPackages desktopApps
xdg-user-dirs-update

echo "Installing fonts"
declare -A fonts=(
  ["pacman:adobe-source-han-sans-otc-fonts"]="Adobe fonts for CN, KR, JP compat"
  ["pacman:ttf-font-awesome"]="Dependency for powerline"
  ["yay:powerline-fonts-git"]="Fonts for the powerline statusline plugin"
  ["yay:ttf-font-icons"]="A set of icons and symbols for TTF fonts"
  ["yay:ttf-ionics"]="A set of icons and symbols for TTF fonts"
  ["yay:ttf-roboto-mono"]="Monospaced font family for user interface and coding environments"
)
installPackages fonts

echo "Installing apps"
declare -A apps=(
  ["pacman:chromium"]="A web browser built for speed, simplicity, and security"
  ["pacman:discord"]="All-in-one voice and text chat"
  ["pacman:p7zip"]="Compression tool"
  ["pacman:powerline"]="Statusline plugin for vim"
  ["pacman:tree"]="Show directory structures in cli"
)
installPackages apps

# declare -A dev=(
#   ["pacman:docker"]="Container runtime"
#   ["pacman:docker-compose"]="Container runtime"
#   ["pacman:go"]="Go"
#   ["yay:nvm"]="Node version manager"
#   ["pacman:python-pip"]="The PyPA recommended tool for installing Python packages"
#   ["pacman:python-psutil"]="Required by a lot of packages"
# )

# echo "Installing dev environment"
# installPackages dev
# echo "Setting up NVM"
# mkdir -p ~/.nvm
# echo "export NVM_DIR=\"$HOME/.nvm\"" >>$HOME/.zshrc
# echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"  # This loads nvm" >>$HOME/.zshrc
# echo "[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\"  # This loads nvm bash_completion" >>$HOME/.zshrc

echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-------------------------------------------------------------------------
"
read -p "Press enter to continue"
exit
