#!/usr/bin/env bash

CONFIG_FILE=$BASE_DIR/x-setup.conf
if [ ! -f "$CONFIG_FILE" ]; then # check if file exists
  touch -f "$CONFIG_FILE"        # create file if not exists
fi

set_option() {
  if grep -Eq "^${1}.*" "$CONFIG_FILE"; then # check if option exists
    sed -i -e "/^${1}.*/d" "$CONFIG_FILE"    # delete option if exists
  fi
  echo "${1}=${2}" >>"$CONFIG_FILE" # add option
}

set_password() {
  read -rs -p "Please enter password: " PASSWORD1
  echo -ne "\n"
  read -rs -p "Please re-enter password: " PASSWORD2
  echo -ne "\n"
  if [[ "$PASSWORD1" == "$PASSWORD2" ]]; then
    set_option "$1" "$PASSWORD1"
  else
    echo -ne "ERROR! Passwords do not match. \n"
    set_password
  fi
}

root_check() {
  if [[ "$(id -u)" != "0" ]]; then
    echo -ne "ERROR! This script must be run under the 'root' user!\n"
    exit 0
  fi
}

docker_check() {
  if awk -F/ '$2 == "docker"' /proc/self/cgroup | read -r; then
    echo -ne "ERROR! Docker container is not supported (at the moment)\n"
    exit 0
  elif [[ -f /.dockerenv ]]; then
    echo -ne "ERROR! Docker container is not supported (at the moment)\n"
    exit 0
  fi
}

arch_check() {
  if [[ ! -e /etc/arch-release ]]; then
    echo -ne "ERROR! This script must be run in Arch Linux!\n"
    exit 0
  fi
}

pacman_check() {
  if [[ -f /var/lib/pacman/db.lck ]]; then
    echo "ERROR! Pacman is blocked."
    echo -ne "If not running remove /var/lib/pacman/db.lck.\n"
    exit 0
  fi
}

background_checks() {
  root_check
  arch_check
  pacman_check
  docker_check
}

userinfo() {
  set_password "PASSWORD"
}

# Starting functions
background_checks
userinfo
