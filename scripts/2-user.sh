#!/usr/bin/env bash
#github-action genshdoc
#
# @file User
# @brief User customizations and AUR package installation.
echo -ne "
-------------------------------------------------------------------------
                        SCRIPTHOME: ArchCrystal
-------------------------------------------------------------------------
"
source $HOME/archcrystal/setup.conf

echo -ne "
-------------------------------------------------------------------------
                        Installing AUR Helper
-------------------------------------------------------------------------
"
cd ~
git clone "https://aur.archlinux.org/yay.git"
cd ~/yay
makepkg -si --noconfirm
cd ~

echo -ne "
-------------------------------------------------------------------------
                        Power Management
-------------------------------------------------------------------------
"
sudo pacman -S --noconfirm --needed thermald acpid power-profiles-daemon
sudo systemctl enable --now thermald
sudo systemctl enable --now acpid
sudo systemctl enable --now power-profiles-daemon

echo -ne "
-------------------------------------------------------------------------
                            Fonts
-------------------------------------------------------------------------
"
sudo pacman -S --noconfirm --needed \
  powerline ttf-font-awesome ttf-roboto ttf-roboto-mono ttf-dejavu \
  ttf-liberation ttf-droid ttf-ubuntu-font-family otf-montserrat \
  ttf-fira-code ttf-fira-mono ttf-fira-sans \
  adibe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts

yay -S --noconfirm --needed \
  ttf-font-icons ttf-ionicons powerline-fonts ttf-google-fonts-git

echo -ne "
-------------------------------------------------------------------------
                      Desktop Environment
-------------------------------------------------------------------------
"
sudo pacman -S --noconfirm --needed \
  xdg-user-dirs polkit-gnome gnome-keyring seahorse nautilus \
  notification-daemon dunst lightscreen i3 i3status rofi

echo -ne "
-------------------------------------------------------------------------
                        Applications
-------------------------------------------------------------------------
"
sudo pacman -S --noconfirm --needed \
  chromium discord p7zip which htop

yay -S --noconfirm --needed \
  spotify- slack-desktop cursor-appimage

echo -ne "
-------------------------------------------------------------------------
                        Development
-------------------------------------------------------------------------
"
sudo pacman -S --noconfirm --needed \
  git docker docker-compose nodejs npm jdk-openjdk virtualbox

echo -ne "
-------------------------------------------------------------------------
                        Compatibility
-------------------------------------------------------------------------
"
sudo pacman -S --noconfirm --needed \
  libx11 libxft libxinerama binutils dosfstools dialog fuse3 libdvdcss \
  libtool make ntfs-3g ntp openssh os-prober python-notify python-pip \
  python-psutils

export PATH=$PATH:~/.local/bin

echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-------------------------------------------------------------------------
"
exit
