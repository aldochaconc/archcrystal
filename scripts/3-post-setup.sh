#!/usr/bin/env bash

echo "GRUB EFI Bootloader Install & Check"
source ${HOME}/archcrystal/setup.conf

if [[ -d "/sys/firmware/efi" ]]; then
  grub-install --efi-directory=/boot ${DISK}
fi

echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg

# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

cd $pwd
