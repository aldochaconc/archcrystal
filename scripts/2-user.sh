#!/usr/bin/env bash

source $HOME/archcrystal/setup.conf
export PATH=$PATH:~/.local/bin

if ! command -v yay &>/dev/null; then
    echo "SETUP AUR HELPER"
    cd ~ && git clone "https://aur.archlinux.org/yay.git" && cd ~/yay && makepkg -si --noconfirm && cd ~
else
    echo "yay is already installed"
fi
yay -Sc --noconfirm

echo -ne "SETUP TERMINAL"
sudo pacman -S rxvt-unicode urxvt-perls zsh
sudo chsh -s /bin/zsh
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo -ne "SETUP XORG SERVER"
sudo pacman -S --noconfirm --needed xorg-server xorg-server-utils xorg-xinit

echo -ne "SETUP DRIVERS"
echo -ne "GRAPHIC DRIVER"
echo -ne "GPU Type: ${gpu_type}"
if grep -E "NVIDIA|GeForce" <<<${gpu_type}; then
    sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings opencl-nvidia lib32-nvidia-utils
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    sudo pacman -S --noconfirm --needed xf86-video-amdgpu
elif grep -E "Integrated Graphics Controller" <<<${gpu_type}; then
    sudo pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
elif grep -E "Intel Corporation UHD" <<<${gpu_type}; then
    sudo pacman -S --needed --noconfirm libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
fi

echo -ne "AUDIO DRIVER"
sudo pacman -S --noconfirm --needed pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber helvum
systemctl --user enable pipewire.socket
systemctl --user enable pipewire-pulse.socket
systemctl --user enable wireplumber.service

echo -ne "BLUETOOTH DRIVER"
sudo pacman -S --noconfirm --needed bluez bluez-utils
sudo systemctl enable bluetooth.service

echo -ne "HARDWARE"
sudo pacman -S --noconfirm --needed acpid brightnessctl cpupower
sudo systemctl enable acpid
sudo systemctl enable cpupower

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
echo -ne "I3WM"
sudo pacman -S --noconfirm --needed i3-gaps i3blocks i3lock numlockx dmenu
sudo pacman -S --noconfirm --needed rofi feh

echo -ne "FONTS"
sudo pacman -S --noconfirm --needed noto-fonts ttf-ubuntu-font-family ttf-dejavu ttf-freefont
sudo pacman -S --noconfirm --needed ttf-liberation ttf-droid ttf-roboto terminus-font
sudo pacman -S --noconfirm --needed adobe-source-han-sans-otc-fonts ttf-fira-code ttf-font-awesome


echo -ne "Installing utilities"
sudo pacman -S --noconfirm --needed htop neofetch ncdu tree p7zip ufw
sudo systemctl enable ufw --now
sudo ufw enable
sudo ufw status
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo -ne "SYSTEM READY FOR 3-post-setup.sh"
read -p "Press enter to continue"
exit
