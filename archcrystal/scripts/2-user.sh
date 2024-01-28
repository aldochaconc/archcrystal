#!/usr/bin/env bash
#github-action genshdoc
#
# @file User
# @brief User customizations and AUR package installation.
echo -ne "
-------------------------------------------------------------------------
                        SCRIPTHOME: ArchCrystal
-------------------------------------------------------------------------

Installing AUR Softwares
"
source $HOME/archcrystal/setup.conf

while read line; do
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done <${HOME}/archcrystal/desktop-env.txt

cd ~
git clone "https://aur.archlinux.org/yay.git"
cd ~/yay
makepkg -si --noconfirm
# sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
# stop the script and move on, not installing any more packages below that line
while read line; do
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done <${HOME}/archcrystal/yay.txt

while read line; do
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done <${HOME}/archcrystal/fonts.txt

export PATH=$PATH:~/.local/bin

echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-------------------------------------------------------------------------
"
exit
