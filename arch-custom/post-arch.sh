#!/bin/bash

# Exit on error
set -e

# Update package database
sudo pacman -Syu --noconfirm

# Function to Install Packages
install_packages() {
    # Essentials
    sudo pacman -S --needed --noconfirm \
        base-devel git curl wget vim code \
        python nodejs npm go rust jdk-openjdk \
        nginx postgresql mariadb sqlite ntfs-3g \
        libimobiledevice ifuse p7zip zathura mpv \
        nmap htop gnome-tweaks nautilus \
        xdg-user-dirs ncdu neofetch mypy \
        networkmanager nvm

    # X11 and WM
    sudo pacman -S --needed --noconfirm xorg xorg-xinit qtile

    # Terminal and Shell
    sudo pacman -S --needed --noconfirm zsh rxvt-unicode

    # Dev Tools
    sudo pacman -S --needed --noconfirm docker docker-compose \
        visual-studio-code-bin
    
    # Media and Utilities
    sudo pacman -S --needed --noconfirm pulseaudio pulseaudio-alsa \
        pulseaudio-utils lightscreen chromium

    # Fonts
    sudo pacman -S --needed --noconfirm noto-fonts-cjk \
        noto-fonts-emoji ttf-dejavu montserrat-otf

    # Android Tools
    sudo pacman -S --needed --noconfirm android-tools adb

    # ThinkPad T430
    sudo pacman -S --needed --noconfirm xf86-video-intel

    # Webcam, Microphone, Bluetooth, Audio, Keyboard
    sudo pacman -S --needed --noconfirm cheese bluez \
        bluez-utils pulseaudio-bluetooth xbacklight
}

install_aur_packages() {
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
    yay -S --needed --noconfirm pywal rofi displaylink \
        libimobiledevices postman-bin mongodb thinkfan
}

configure_zsh() {
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

configure_ime() {
    sudo pacman -S --needed --noconfirm ibus ibus-mozc
    echo 'export GTK_IM_MODULE=ibus' >> ~/.zshrc
    echo 'export XMODIFIERS=@im=ibus' >> ~/.zshrc
    echo 'export QT_IM_MODULE=ibus' >> ~/.zshrc
}

configure_hardware() {
    sudo pacman -S --needed --noconfirm intel-ucode
    sudo systemctl enable fstrim.timer
    sudo systemctl enable NetworkManager.service
    sudo systemctl enable docker.service
    sudo systemctl enable bluetooth.service
}

echo "Starting post-install setup..."
install_packages
install_aur_packages
configure_zsh
configure_ime
configure_hardware
echo "Post-install setup complete!"
