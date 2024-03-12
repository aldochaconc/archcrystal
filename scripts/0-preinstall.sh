#!/usr/bin/env bash

echo "Setting up installer environment"
source $BASE_DIR/setup.conf
pacman -Sy --noconfirm archlinux-keyring

iso=$(curl -4 ifconfig.co/country-iso)
timedatectl set-ntp true

echo -ne "Enabling parallel downloads"
pacman -S --noconfirm --needed pacman-contrib reflector rsync grub
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
mkdir /mnt &>/dev/null

echo -ne "Formatting Disk"
pacman -S --noconfirm --needed gptfdisk btrfs-progs glibc
umount -A --recursive /mnt &>/dev/null

echo "Wiping Disk"
sgdisk -Z ${DISK}
sgdisk -a 2048 -o ${DISK}

echo "Partitioning Disk"
sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${DISK}
sgdisk -n 2::+1G --typecode=2:ef00 --change-name=2:'EFIBOOT' ${DISK}
sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' ${DISK}

if [[ ! -d "/sys/firmware/efi" ]]; then
    sgdisk -A 1:set:2 ${DISK}
fi
partprobe ${DISK}

echo -ne "Creating Filesystems"
createsubvolumes() {
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@var
    btrfs subvolume create /mnt/@tmp
    btrfs subvolume create /mnt/@.snapshots
}
mountallsubvol() {
    mount -o ${MOUNT_OPTIONS},subvol=@home ${partition3} /mnt/home
    mount -o ${MOUNT_OPTIONS},subvol=@tmp ${partition3} /mnt/tmp
    mount -o ${MOUNT_OPTIONS},subvol=@var ${partition3} /mnt/var
    mount -o ${MOUNT_OPTIONS},subvol=@.snapshots ${partition3} /mnt/.snapshots
}
subvolumesetup() {
    createsubvolumes
    umount /mnt
    mount -o ${MOUNT_OPTIONS},subvol=@ ${partition3} /mnt
    mkdir -p /mnt/{home,var,tmp,.snapshots}
    mountallsubvol
}

# In the configuration file, the options can be /dev/sda or /dev/nvme0n1
if [[ ${DISK} =~ "nvme" ]]; then
    partition2=${DISK}p2
    partition3=${DISK}p3
else
    partition2=${DISK}2
    partition3=${DISK}3
fi

mkfs.vfat -F32 -n "EFIBOOT" ${partition2}
mkfs.ext4 -L ROOT ${partition3}
mount -t ext4 ${partition3} /mnt

mkdir -p /mnt/boot/efi
mount -t vfat -L EFIBOOT /mnt/boot/

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Drive is not mounted can not continue"
    echo "Rebooting in 3 Seconds ..." && sleep 1
    echo "Rebooting in 2 Seconds ..." && sleep 1
    echo "Rebooting in 1 Second ..." && sleep 1
    reboot now
fi
echo -ne "Pacstrapping Archlinux base system"
pacstrap /mnt \
    archlinux-keyring \
    base \
    base-devel \
    git \
    linux \
    linux-firmware \
    linux-headers \
    sudo \
    vim \
    wget \
    pacman-contrib \
--noconfirm --needed

cp -R ${BASE_DIR} /mnt/root/archcrystal

echo "Generating FSTAB"
genfstab -L /mnt >>/mnt/etc/fstab
cat /mnt/etc/fstab

echo "Setting up boot"
if [[ ! -d "/sys/firmware/efi" ]]; then
    grub-install --boot-directory=/mnt/boot ${DISK}
else
    pacstrap /mnt efibootmgr --noconfirm --needed
fi
