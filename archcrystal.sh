#!/bin/bash
# Script Name: archcrystal.sh
# Version: 1.1.0

set -a
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
SCRIPTS="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"/scripts

set +a

(bash $BASE_DIR/scripts/startup.sh) |& tee startup.log
source $BASE_DIR/setup.conf
(bash $BASE_DIR/scripts/0-preinstall.sh) |& tee 0-preinstall.log
(arch-chroot /mnt $HOME/archcrystal/scripts/1-setup.sh) |& tee 1-setup.log
(arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /home/$USERNAME/archcrystal/scripts/2-user.sh) |& tee 2-user.log
(arch-chroot /mnt $HOME/archcrystal/scripts/3-post-setup.sh) |& tee 3-post-setup.log
cp -v *.log /mnt/home/$USERNAME

echo -ne "
-------------------------------------------------------------------------
                    Installation Complete
-------------------------------------------------------------------------
"
