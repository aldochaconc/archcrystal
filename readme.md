# Archcrystal

## Description

A fork of the ArchTitus script installation for Archlinuxm with tweaks to achieve

- Minimal configuration file.
- Minimal prompt for user input.
- All necessary packages for a functional laptop environment
- A tailored environment for my personal Thinkpad T430 laptop.

## Motivation

I don't have special attatchment to laptop's and settings because I'm constantly changing my work environment.
I work as developer and recently had to use my Thinkpad T430 fully upgraded at my work (as an emergency).  
The performance was excellent and the process was the exact same that I use in all computers that I have to setup.

Creating this scripts is a way to document the cleanest but functional environment that I've achieved, and also a way to log my learnig in linux and shell scripting.

## How to use

- `archcrystal.sh` is the entry point.
- Check the `archcrystal.sh` file to understand the execution order.
- `setup.conf` contains basic environment configuration.

1. Download an Archlinux iso and run it.
2. Sync pacman & install git using `pacman -Syy git`.
3. Clone archcrystal using `git clone https://github.com/aldochaconc/archcrystal.git`.
4. Grant execute permissions to files with `chmod +x -R ./archcrystal/*`.
5. Run the script using `cd archcrystal` & `./archcrystal.sh`.

Once the script starts, it will prompt for your password.
This is the only prompt that requires user input.
Later, there are "press to continue" prompts to verify what you are installing.

## The script

### 0-preinstall.sh

- Sets up mirrors for optimal download speed.
- Updates the keyring to prevent packages from failing to install.
- Installs prerequisites like `gptfdisk`, `btrfs-progs`, and `glibc`.
- Formats the disk, creates partitions, and makes filesystems.
- Creates btrfs subvolumes and mounts them.
- Checks if the drive is mounted, if not, reboots the system.
- Installs base packages on the main drive and pacstraps them.
- Generates the fstab file.
- Installs the appropriate bootloader (GRUB or systemd-boot).

### 1-setup.sh

- Sets up the network and installs necessary packages.
- Sets up Pacman mirrors for optimal download speed.
- Adjusts makeflags and compression settings based on the number of cores and total memory.
- Sets up language, locale, and keymap.
- Enables sudo without password for the wheel group, parallel downloading, and multilib in Pacman.
- Installs the base system, microcode based on the processor type, graphics drivers based on the GPU type, and audio drivers.
- Adds a new user, sets password, and hostname.
- Prompts the user to proceed to the `2-user.sh` script.

### 2-user.sh

- Checks and installs the AUR helper `yay`.
- Defines a function to install a list of packages using `pacman` or `yay`.
- Declares an array of packages to be installed, including essential, environment, monitoring, network, OS compatibility, drivers, fonts, desktop environment, and application packages.
- Sets ZSH as the default shell and installs Oh My ZSH.
- Enables several services like `acpid`, `bluetooth`, `cups`, `NetworkManager`, `ntpd`, `thermald`, `ufw`, `paccache.timer`, and `trim.timer`.
- Prompts the user to proceed to the `3-post-setup.sh` script.

### 3-post-setup.sh

- Updates grub settings.
- Removes no password sudo rights.
- (Not cleaning due to debugging)
