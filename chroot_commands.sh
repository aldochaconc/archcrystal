#!/bin/sh
set -xe
sed -i "s/^#en_US.UTF-8/en_US.UTF-8/g" /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen

ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc
systemctl enable NetworkManager

echo root:123 | chpasswd
echo "archer" > /etc/hostname

mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB