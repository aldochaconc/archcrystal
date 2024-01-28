#!/usr/bin/env bash
#github-action genshdoc
#
# @file User
# @brief User customizations and AUR package installation.
echo -ne "
-------------------------------------------------------------------------
                        SCRIPTHOME: ArchTitus
-------------------------------------------------------------------------

Installing AUR Softwares
"
source $HOME/ArchCrystal/x-setup.conf

cd ~
mkdir "/home/$USERNAME/.cache"
touch "/home/$USERNAME/.cache/zshhistory"
git clone "https://github.com/ChrisTitusTech/zsh"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
ln -s "~/zsh/.zshrc" ~/.zshrc

while read line; do
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done <~/ArchCrystal/pkgs-desktop-env.txt

cd ~
git clone "https://aur.archlinux.org/yay.git"
cd ~/yay
makepkg -si --noconfirm
# sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
# stop the script and move on, not installing any more packages below that line
while read line; do
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done <~/ArchCrystal/pkgs-yay.txt

while read line; do
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done <~/ArchCrystal/pkgs-fonts.txt

export PATH=$PATH:~/.local/bin

echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-------------------------------------------------------------------------
"
exit
