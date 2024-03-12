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

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
echo "Terminal setup"
sudo pacman -S rxvt-unicode urxvt-perls zsh
echo "Setting up ZSH as default shell"
chsh -s /bin/zsh
echo "Installing oh-my-zsh"
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
echo "Setting up Xorg server"
pacman -S xorg-server xorg-server-utils xorg-xinit

echo "Installing drivers"
echo "GPU Type: ${gpu_type}"
if grep -E "NVIDIA|GeForce" <<<${gpu_type}; then
    sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings opencl-nvidia xorg-server-devel lib32-nvidia-utils
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    sudo pacman -S --noconfirm --needed xf86-video-amdgpu
elif grep -E "Integrated Graphics Controller" <<<${gpu_type}; then
    sudo pacman -S --noconfirm --needed \
        libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
elif grep -E "Intel Corporation UHD" <<<${gpu_type}; then
    sudo pacman -S --needed --noconfirm \
        libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
fi

echo "AUDIO DRIVER"
sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber helvum
systemctl --user enable pipewire.socket
systemctl --user enable pipewire-pulse.socket
systemctl --user enable wireplumber.service

echo "BLUETOOTH DRIVER"
sudo pacman -S bluez bluez-utils
sudo systemctl enable bluetooth.service

echo "HARDWARE"
sudo pacman -S acpid brightnessctl cpupower
sudo systemctl enable acpid
sudo systemctl enable cpupower

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
echo "Installing i3 with KDE"
sudo pacman -S i3-gaps i3blocks i3lock numlockx i3-dmenu-desktop
sudo pacman -S rofi feh

echo "Installing fonts"
sudo pacman -S noto-fonts ttf-ubuntu-font-family ttf-dejavu ttf-freefont
sudo pacman -S ttf-liberation ttf-droid ttf-roboto terminus-font
sudo pacman -S adobe-source-han-sans-otc-fonts ttf-fira-code ttf-font-awesome


echo "Installing utilities"
sudo pacman -S htop neofetch ncdu tree p7zip ufw
sudo systemctl enable ufw --now
ufw enable
ufw status
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "SYSTEM READY FOR 3-post-setup.sh"
read -p "Press enter to continue"
exit
