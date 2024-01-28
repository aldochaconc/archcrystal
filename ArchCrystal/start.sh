#!/bin/bash

set -a
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIGS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"/configs

set +a

(bash $BASE_DIR/environment.sh) |& tee startup.log
source $BASE_DIR/setup.conf
(bash $BASE_DIR/0-preinstall.sh) |& tee 0-preinstall.log
(arch-chroot /mnt $HOME/1-setup.sh) |& tee 1-setup.log
(arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /home/$USERNAME/2-user.sh) |& tee 2-user.log
(arch-chroot /mnt $HOME/3-post-setup.sh) |& tee 3-post-setup.log
cp -v *.log /mnt/home/$USERNAME

echo -ne "
-------------------------------------------------------------------------
                    Installation Complete
-------------------------------------------------------------------------
"
