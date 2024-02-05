# Archcrystal

## What the heck?

A streamlined automated Arch Linux installation script for personal use.
This script automates all the fundamental processes of installing Arch Linux, including disk partitioning, system setup, user setup, and package installation.
It's a fork of the original ArchTitus script, but with significantly less code and fewer user prompts.

## Motivation

I enjoy breaking things with Linux (honestly).  
Someone once told me that if you eyecandy your Linux env, then you must have a lot of time.
That's why this script automates all the basic requirements for a functional, work-ready environment, tailored to my personal Thinkpad T430 laptop.

## Perks

- The script is designed to be as minimal as possible, but functional enough to be used right away.
- The user configuration contains a list of packages by contexts. They have description, read them and be sure of what you're installing.

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

## Things kept from the original script:

- Environment variables management.
- Disk partitioning and disk utilities.
- Mirrorlists and keyring updates.
- Compression settings.
- Graphic drivers auto detection.

### 0-preinstall.sh

- Sets up Pacman optimal mirrors.
- Updates keyring.
- Partitions, formats, and mounts the disk.
  Installs base packages on the main drive and pacstraps them.
- Generates the fstab file.
- Installs the appropriate bootloader (GRUB or systemd-boot).

### 1-setup.sh

Arch-chroot operations

- Sets up Network, Pacman mirrorlist, and system clock.
- Language, locale, and keymap setup.
- Enables sudo without password for wheel group and multilib in Pacman.
- Installs base system, microcode, graphics, and audio drivers.
- Adds a new user, sets password, and hostname.

### 2-user.sh

- Installs YAY AUR helper.
- Defines lists of packages to install by context.
- Declares functions to install packages using pacman and yay.
- Sets ZSH as default shell.
- Installs and configures Oh My ZSH.
- Enables installed services.

### 3-post-setup.sh

- Updates grub settings.
- Removes no password sudo rights.
- (Not cleaning due to debugging)
