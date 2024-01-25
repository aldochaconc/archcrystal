#!/bin/sh
set -xe
sed -i "s/^#en_US.UTF-8/en_US.UTF-8/g" /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen

# Set the timezone to Santiago, Chile.
ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime
hwclock --systohc

# Set the keyboard layout to English/Japanese.
localectl set-keymap jp106

systemctl enable NetworkManager

# Set the root password.
echo "root:$root_password" | chpasswd

# Create the second user and set their password.
useradd -m -G wheel -s /bin/bash $username
echo "$username:$user_password" | chpasswd

# Uncomment the line in the sudoers file that allows members of the wheel group to use sudo.
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Set the hostname.
echo "$hostname" > /etc/hostname

# Enable parallel downloads in pacman.
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf || echo "ParallelDownloads = 5" >> /etc/pacman.conf

mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB