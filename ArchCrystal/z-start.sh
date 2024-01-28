#!/bin/bash
# shellcheck source=/dev/null
set -a
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
set +a

# (bash $BASE_DIR/y-environment.sh) |& tee startup.log
source $BASE_DIR/x-setup.conf
# (bash $BASE_DIR/0-preinstall.sh) |& tee 0-preinstall.log
cat $BASE_DIR/x-setup.conf

cp ${BASE_DIR}/x-setup.conf /mnt/root/ArchCrystal/x-setup.conf
cp ${BASE_DIR}/1-setup.sh /mnt/root/ArchCrystal/1-setup.sh
cp ${BASE_DIR}/2-user.sh /mnt/root/ArchCrystal/2-user.sh
cp ${BASE_DIR}/3-post-setup.sh /mnt/root/ArchCrystal/3-post-setup.sh
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

(arch-chroot /mnt $HOME/ArchCrystal/1-setup.sh) |& tee 1-setup.log
(arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /home/$USERNAME/ArchCrystal/2-user.sh) |& tee 2-user.log
(arch-chroot /mnt $HOME/ArchCrystal/3-post-setup.sh) |& tee 3-post-setup.log
cp -v *.log /mnt/home/$USERNAME

echo -ne "
-------------------------------------------------------------------------
                    Installation Complete
-------------------------------------------------------------------------
"
