#!/bin/sh
# Arch Linux installer script. EFI only!

[ -z "$1" ] && printf "Usage: Provide only the drive to install to (i.e /dev/sda, see lsblk)\n\n./archstrap.sh [DRIVE]\n\n" && exit
[ ! -b "$1" ] && printf "Drive $1 is not a valid block device.\n" && exit
printf "\nThis script will erase all data on $1.\nAre you certain? (y/n): " && read CERTAIN
[ "$CERTAIN" != "y" ] && printf "Abort." && exit

disk=$1
boot=${disk}1
swap=${disk}2
root=${disk}3
home=${disk}4

# Cleanup from previous runs.
swapoff $swap
umount -R /mnt

# Partition 512 MiB for boot, 12G for swap, 50G for root and rest to home.
# Optimal alignment will change the exact size though!
set -xe
parted -s $disk mklabel gpt
parted -sa optimal $disk mkpart primary fat32 0% 512MiB
parted -sa optimal $disk mkpart primary linux-swap 512MiB 15G
parted -sa optimal $disk mkpart primary ext4 15G 70G
parted -sa optimal $disk mkpart primary ext4 70G 100%
parted -s $disk set 1 esp on

# Format the partitions.
mkfs.fat -IF32 $boot
mkswap -f $swap
mkfs.ext4 -F $root
mkfs.ext4 -F $home

# Mount the partitions.
mount $root /mnt
mount -m $boot /mnt/boot
mount -m $home /mnt/home
swapon $swap

# Packages and chroot.
pacstrap /mnt linux linux-firmware networkmanager vim base base-devel git man efibootmgr grub
genfstab -U /mnt > /mnt/etc/fstab

# Enter the system and set up basic locale, passwords and bootloader.
arch-chroot /mnt sh -c 'set -xe;
sed -i "s/^#en_US.UTF-8/en_US.UTF-8/g" /etc/locale.gen;
echo "LANG=en_US.UTF-8" > /etc/locale.conf;
locale-gen;

ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime;
hwclock --systohc;
systemctl enable NetworkManager;

echo root:123 | chpasswd;
echo "archer" > /etc/hostname;

mkdir /boot/grub;
grub-mkconfig -o /boot/grub/grub.cfg;
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB;'

# Finalize.
umount -R /mnt
set +xe

printf "
        *--- Installation Complete! ---*
        |                              |
        |        Username: root        |
        |        Password: 123         |
        |                              |
        *------------------------------*

"