#!/usr/bin/env bash

echo -ne "

Final Setup and  -SConfigurations
GRUB EFI Bootloader Install & Check

"
source ${HOME}/archcrystal/setup.conf

if [[ -d "/sys/firmware/efi" ]]; then
  grub-install --efi-directory=/boot ${DISK}
fi

echo -ne "

Creating (and Theming) Grub Boot Menu

"
echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

echo -ne "

Cleaning

"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Replace in the same state
cd $pwd
