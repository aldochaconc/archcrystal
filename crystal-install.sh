#!/bin/sh
# Arch Linux installer script. EFI only!

[ -z "$1" ] && printf "Usage: Provide only the drive to install to (i.e /dev/sda, see lsblk)\n\n./archstrap.sh [DRIVE]\n\n" && exit
[ ! -b "$1" ] && printf "Drive $1 is not a valid block device.\n" && exit
printf "\nThis script will erase all data on $1.\nAre you certain? (y/n): " && read CERTAIN
[ "$CERTAIN" != "y" ] && printf "Abort." && exit

#!/bin/sh
# Arch Linux installer script. EFI only!

# Prompt for the username and password of the second user.
echo "Enter the username of your user (this will also be the hostname):"
read username
export username
echo "Enter the password for $username:"
read -s user_password
export user_password

# Set the hostname to be the same as the username.
hostname=$username
export hostname

# Set the locale, localtime, and keymap.
locale_lang="en_US.UTF-8"
export locale_lang
localtime="/usr/share/zoneinfo/America/Santiago"
export localtime
keymap="jp106"
export keymap

# Set the partition schema.
partition_schema="/dev/sda"
export partition_schema

# Print a brief with the installation configs.
echo "Installation configs:"
echo "Username: $username"
echo "Hostname: $hostname"
echo "Locale Lang: $locale_lang"
echo "Localtime: $localtime"
echo "Keymap: $keymap"
echo "Partition Schema: $partition_schema"
echo "Current partition layout:"
fdisk -l $partition_schema

# Prompt for confirmation before continuing.
echo "Do you want to continue with these settings? (y/n)"
read confirmation
if [ "$confirmation" != "y" ]; then
    echo "Installation cancelled."
    exit 1
fi

disk=$1
boot=${disk}1
swap=${disk}2
root=${disk}3

# Cleanup from previous runs.
if swapon --summary | grep -q "$swap"; then
    swapoff $swap
fi
umount -R /mnt || true

# # Partition 1GB for boot, 3GB for swap, rest for root.
# # Optimal alignment will change the exact size though!
# set -xe
# parted -s $disk mklabel gpt
# parted -sa optimal $disk mkpart primary fat32 0% 1GB
# parted -sa optimal $disk mkpart primary linux-swap 1GB 4GB
# parted -sa optimal $disk mkpart primary ext4 4GB 100%
# parted -s $disk set 1 esp on

# # Format the partitions.
# mkfs.fat -IF32 $boot
# mkswap -f $swap
# mkfs.ext4 -F $root

# Mount the partitions.
mount $root /mnt
mkdir -p /mnt/boot
mount $boot /mnt/boot
swapon $swap

# Enable parallel downloads in pacman.
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf || echo "ParallelDownloads = 5" >> /etc/pacman.conf

# # Packages and chroot.
# pacstrap /mnt linux linux-firmware networkmanager vim base base-devel git man efibootmgr grub
# genfstab -U /mnt > /mnt/etc/fstab

# Enter the system and set up basic locale, passwords and bootloader.
arch-chroot /mnt sh -c "set -xe"

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