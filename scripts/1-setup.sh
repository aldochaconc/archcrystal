#!/usr/bin/env bash

echo -ne "Setting up archcrystal"
source $HOME/archcrystal/setup.conf

echo "Setting up Network"
pacman -S --noconfirm --needed networkmanager dhclient ntp
systemctl enable --now NetworkManager
systemctl enable --now dhclient
systemctl enable --now ntpd

echo "Setting up Pacman"
pacman -Sy archlinux-keyring

pacman -S --noconfirm --needed pacman-contrib curl reflector rsync grub arch-install-scripts git
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm --needed
sed -i '35 i ILoveCandy' /etc/pacman.conf
sed -i 's/#Color/Color/' /etc/pacman.conf
systemctl enable paccache.timer
systemctl enable trim.timer

echo "Setting up compression settings"
nc=$(grep -c ^processor /proc/cpuinfo)
TOTAL_MEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[ $TOTAL_MEM -gt 8000000 ]]; then
    sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
    sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
fi

echo "Setup Language, locale and keymap"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone ${TIMEZONE}
timedatectl --no-ask-password set-ntp 1
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf
echo "LC_TIME=en_US.UTF-8" >>/etc/locale.conf
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
echo "KEYMAP=${KEYMAP}" >/etc/vconsole.conf

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

echo -ne "Pacstrapping Base System"

pacman -S --noconfirm --needed mesa ibus man-db vim
echo -ne "
Installing Microcode
"
# determine processor type and install microcode
proc_type=$(lscpu)
if grep -E "GenuineIntel" <<<${proc_type}; then
    echo "Installing Intel microcode"
    pacman -S --noconfirm --needed intel-ucode
    proc_ucode=intel-ucode.img
elif grep -E "AuthenticAMD" <<<${proc_type}; then
    echo "Installing AMD microcode"
    pacman -S --noconfirm --needed amd-ucode
    proc_ucode=amd-ucode.img
fi

echo -ne "

Installing Graphics Drivers

"
# Graphics Drivers find and install
gpu_type=$(lspci)
echo "GPU Type: ${gpu_type}"
if grep -E "NVIDIA|GeForce" <<<${gpu_type}; then
    pacman -S --noconfirm --needed nvidia
    nvidia-xconfig
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    pacman -S --noconfirm --needed xf86-video-amdgpu
elif grep -E "Integrated Graphics Controller" <<<${gpu_type}; then
    pacman -S --noconfirm --needed \
        libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
elif grep -E "Intel Corporation UHD" <<<${gpu_type}; then
    pacman -S --needed --noconfirm \
        libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
fi

#SETUP IS WRONG THIS IS RUN
if ! source $HOME/archcrystal/setup.conf; then
    # Loop through user input until the user gives a valid username
    while true; do
        read -p "Please enter username:" username
        # username regex per response here https://unix.stackexchange.com/questions/157426/what-is-the-regex-to-validate-linux-users
        # lowercase the username to test regex
        if [[ ${username,,} =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]; then
            break
        fi
        echo "Incorrect username."
    done
    # convert name to lowercase before saving to setup.conf
    echo "username=${username,,}" >>${HOME}/setup.conf

    #Set Password
    read -p "Please enter password:" password
    echo "password=${password,,}" >>${HOME}/setup.conf

    # Loop through user input until the user gives a valid hostname, but allow the user to force save
    while true; do
        read -p "Please name your machine:" name_of_machine
        # hostname regex (!!couldn't find spec for computer name!!)
        if [[ ${name_of_machine,,} =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]; then
            break
        fi
        # if validation fails allow the user to force saving of the hostname
        read -p "Hostname doesn't seem correct. Do you still want to save it? (y/n)" force
        if [[ ${force,,} = "y" ]]; then
            break
        fi
    done

    echo "NAME_OF_MACHINE=${name_of_machine,,}" >>${HOME}/archcrystal/setup.conf
fi
echo -ne "
Adding User
"
if [ $(whoami) = "root" ]; then
    groupadd libvirt
    useradd -m -G wheel,libvirt -s /bin/bash $USERNAME
    echo "$USERNAME created, home directory created, added to wheel and libvirt group, default shell set to /bin/bash"

    # use chpasswd to enter $USERNAME:$password
    echo "$USERNAME:$PASSWORD" | chpasswd
    echo "$USERNAME password set"

    cp -R $HOME/* /home/$USERNAME/
    chown -R $USERNAME: /home/*
    echo "ArchCrystal copied to home directory"

    # enter $NAME_OF_MACHINE to /etc/hostname
    echo $NAME_OF_MACHINE >/etc/hostname
else
    echo "You are already a user proceed with aur installs"
fi

echo -ne "
SYSTEM READY FOR 2-user.sh
"
read -p "Press enter to continue"
