#!/usr/bin/env bash
#github-action genshdoc
#
# @file User
# @brief User customizations and AUR package installation.

source $HOME/archcrystal/setup.conf
export PATH=$PATH:~/.local/bin

echo -ne "
                        Installing AUR Helper
"
# cd ~
# git clone "https://aur.archlinux.org/yay.git"
# cd ~/yay
# makepkg -si --noconfirm
# cd ~

declare -A powerManagement=(
  ["thermald"]="Thermal daemon for preventing overheating"
  ["acpid"]="Advanced Configuration and Power Interface event daemon"
)

# Provide compat pkgs for iOS and windows. Also libs such as python-psutil, required in a lot of pkgs
declare -A compatibility=(
  ["dosfstools"]="DOS filesystem utilities"
  ["ifuse"]="A fuse filesystem to access the contents of iOS devices"
  ["libimobiledevice"]="A cross-platform librariesand tools for iOS"
  ["libtool"]="A generic library support script"
  ["ntfs-3g"]="NTFS filesystem driver and utilities"
  ["ntp"]="Network Time Protocol"
  ["os-prober"]="For detecting other operative system such as Windows"
  ["python-pip"]="The PyPA recommended tool for installing Python packages"
  ["python-psutil"]="Required by a lot of packages"
)

# Provide user utils for auth, keyring, monitor, compression
declare -A utilities=(
  ["tree"]="A directory listing program displaying a depth indented list of files"
  ["gparted"]="A partition editor for graphically managing your disk partitions"
  ["powerline"]="Statusline plugin for vim"
  ["htop"]="Interactive process viewer"
  ["p7zip"]="Command-line file archiver with high compression ratio"
  ["neofetch"]="A fast, highly customizable system info script"
  ["ncdu"]="A disk usage analyzer with a ncurses interface"

)

declare -A pacmanFonts=(
  ["adobe-source-han-sans-otc-fonts"]="Adobe fonts for CN, KR, JP compat"
  ["adobe-source-han-serif-otc-fonts"]="Adobe fonts for CN, KR, JP compat"
  ["otf-montserrat"]="Geometric sans-serif typeface"
  ["ttf-fira-mono"]="Monospaced font with programming ligatures"
  ["ttf-fira-sans"]="Geometric sans-serif typeface"
  ["ttf-font-awesome"]="Iconic font designed for use with Twitter Bootstrap"
  ["ttf-roboto-mono"]="Monospaced font family for user interface and coding environments"
)

declare -A yayFonts=(
  ["powerline-fonts"]="Fonts for the powerline statusline plugin"
  ["ttf-font-icons"]="A set of icons and symbols for TTF fonts"
  # ["ttf-google-fonts-git"]="Google Fonts packaged for Arch Linux"
  # ["ttf-ionicons"]="The premium icon font for Ionic Framework"
)

declare -A desktopEnv=(
  ["arandr"]="A simple visual front end for XRandR"
  ["autorandr"]="Auto-detect screens and update layouts"
  ["dunst"]="Customizable and lightweight notification-daemon"
  ["gnome-keyring"]="Stores passwords and encryption keys"
  ["i3"]="An improved dynamic tiling window manager"
  ["i3status"]="Status bar for i3"
  ["nautilus"]="GNOME file manager"
  ["notification-daemon"]="Notification daemon for the desktop notifications"
  ["pavucontrol"]="PulseAudio Volume Control"
  ["polkit-gnome"]="GNOME frontend to the PolicyKit framework"
  ["rofi"]="A window switcher, application launcher and dmenu replacement"
  ["seahorse"]="GNOME application for managing PGP keys"
  ["xdg-user-dirs"]="Tool to help manage well known user directories"
)

declare -A apps=(
  ["chromium"]="A web browser built for speed, simplicity, and security"
  ["discord"]="All-in-one voice and text chat"
)
declare -A yayApps=(
  ["lightscreen"]="A simple tool to automate screenshots"
)

declare -A devEnv=(
  ["git"]="A distributed version control system"
  ["neovim"]="Vi Improved, a highly configurable, improved version of the vi text editor"
  ["nodejs"]="Evented I/O for V8 javascript"
  ["npm"]="A package manager for javascript"
  ["rxvt-unicode"]="A customizable terminal emulator"
  ["zsh"]="A very advanced and programmable command interpreter (shell) for UNIX"
)

installPacmanPackages() {
  # print the list received as params
  local -n packages=$1
  local toInstall=""
  echo ""
  echo "$2"
  echo "Packages to be installed"
  echo ""
  for package in "${!packages[@]}"; do
    echo "- $package: ${packages[$package]}"
    toInstall+="$package "
  done
  echo ""
  read -p "Press enter to continue"
  # shellcheck disable=SC2086

  sudo pacman -S --noconfirm $toInstall
}
installYayPackages() {
  # print the list received as params
  local -n packages=$1
  local toInstall=""

  echo ""
  echo "$2"

  echo "Packages install:"
  for package in "${!packages[@]}"; do
    echo "- $package: ${packages[$package]}"
    toInstall+="$package "
  done
  echo ""
  read -p "Press enter to continue"
  # shellcheck disable=SC2086
  yay -S --noconfirm $toInstall
}

# Invoke the function from above, with the name of the array
installPacmanPackages powerManagement "Power Management"
installPacmanPackages compatibility "Compatibility"
installPacmanPackages utilities "Utilities"
installPacmanPackages pacmanFonts "Pacman Fonts"
installPacmanPackages desktopEnv "Desktop Environment"
installPacmanPackages apps "Apps"
installPacmanPackages devEnv "Development Environment"

installYayPackages yayFonts "Yay Fonts"
installYayPackages yayApps "Yay Apps"

echo "Setting up ZSH as default shell"
chsh -s /bin/zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Enabling services"
sudo systemctl enable thermald
sudo systemctl enable acpid
sudo systemctl enable power-profiles-daemon
sudo systemctl enable NetworkManager
sudo systemctl enable sshd
sudo systemctl enable ntpd
sudo systemctl enable ufw

echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-------------------------------------------------------------------------
"
read -p "Press enter to continue"
exit
