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
cd ~
git clone "https://aur.archlinux.org/yay.git"
cd ~/yay
makepkg -si --noconfirm
cd ~

declare -A powerManagement=(
  ["thermald"]="Daemon to prevent cpu overheating"
  ["acpid"]="Daemon to dispatch ACPI events"
)

# Provide compat pkgs for iOS and windows. Also libs such as python-psutil, required in a lot of pkgs
declare -A compatibility=(
  ["dosfstools"]="DOS filesystem utilities"
  ["ifuse"]="A fuse filesystem to access the contents of iOS devices"
  ["libimobiledevice"]="A cross-platform librariesand tools for iOS"
  ["libtool"]="A generic library support script"
  ["ntfs-3g"]="NTFS filesystem driver and utilities (windows compat)"
  ["ntp"]="Network Time Protocol"
  ["os-prober"]="For detecting other operative system such as Windows"
  ["python-pip"]="The PyPA recommended tool for installing Python packages"
  ["python-psutil"]="Required by a lot of packages"
)

# Provide user utils for auth, keyring, monitor, compression
declare -A utilities=(
  ["tree"]="Show directory structures in cli"
  ["gparted"]="Manage disks"
  ["powerline"]="Statusline plugin for vim"
  ["htop"]="CLI process administrator"
  ["p7zip"]="Compression tool"
  ["neofetch"]="i use arch btw"
  ["ncdu"]="disk usage cli"

)

declare -A pacmanFonts=(
  ["adobe-source-han-sans-otc-fonts"]="Adobe fonts for CN, KR, JP compat"
  ["adobe-source-han-serif-otc-fonts"]="Adobe fonts for CN, KR, JP compat"
  # ["otf-montserrat"]="Geometric sans-serif typeface"
  # ["ttf-fira-mono"]="Monospaced font with programming ligatures"
  # ["ttf-fira-sans"]="Geometric sans-serif typeface"
  ["ttf-font-awesome"]="Dependency for powerline"
  ["ttf-roboto-mono"]="Monospaced font family for user interface and coding environments"
)

declare -A yayFonts=(
  ["powerline-fonts"]="Fonts for the powerline statusline plugin"
  ["ttf-font-icons"]="A set of icons and symbols for TTF fonts"
  ["nerd-fonts"]="Required for zsh and oh-my-zsh"
  # ["ttf-google-fonts-git"]="Google Fonts packaged for Arch Linux"
  # ["ttf-ionicons"]="The premium icon font for Ionic Framework"
)

declare -A desktopEnv=(
  ["arandr"]="Manage screen layouts"
  ["autorandr"]="Autorefresh screen layouts"
  ["dunst"]="Notification daemon"
  ["secret-tool"]="Allow apps use gnome-keyring"
  ["i3"]="Tiling manager"
  ["i3status"]="i3 dependency (bar)"
  ["gnome-keyring"]="GNOME keyring for psw management"
  ["rofi"]="App launcher"
  ["xdg-user-dirs"]="Setup default dirs"
  ["nautilus"]="GNOME file explorer"
  ["pavucontrol"]="GNOME GUI Volume Control"
  ["polkit-gnome"]="GNOME auth agent (dependency for gui apps)"
  ["seahorse"]="GNOME application for managing PGP keys"
)

declare -A apps=(
  ["chromium"]="A web browser built for speed, simplicity, and security"
  # ["discord"]="All-in-one voice and text chat"
)
declare -A yayApps=(
  ["lightscreen"]="A simple tool to automate screenshots"
)

declare -A devEnv=(
  ["git"]="versioning"
  ["neovim"]="vim fork"
  ["nodejs"]="the best"
  ["rxvt-unicode"]="terminal emulator"
  ["zsh"]="shell"
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
# installPacmanPackages powerManagement "Power Management"
# installPacmanPackages compatibility "Compatibility"
# installPacmanPackages utilities "Utilities"
# installPacmanPackages pacmanFonts "Pacman Fonts"
# installPacmanPackages desktopEnv "Desktop Environment"
# installPacmanPackages apps "Apps"
# installPacmanPackages devEnv "Development Environment"

# installYayPackages yayFonts "Yay Fonts"
# installYayPackages yayApps "Yay Apps"

echo "Setting up ZSH as default shell"
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s /bin/zsh

echo "Enabling services"
sudo systemctl enable thermald
sudo systemctl enable acpid
sudo systemctl enable NetworkManager
sudo systemctl enable sshd
sudo systemctl enable ntpd
sudo systemctl enable bluetooth

echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-------------------------------------------------------------------------
"
read -p "Press enter to continue"
exit
