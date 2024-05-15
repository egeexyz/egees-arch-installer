# Egee's Arch Installer

Welcome to Egee's simple Arch Linux fully-automated installer Github repository.

It's a super-simple script that automates the [manual steps](https://wiki.archlinux.org/title/installation_guide) required to install Arch Linux! The resulting system installed from this script is tiny: 1.2gb installed and about 250mb of memory used at idle.

It's best used as reference architecture for your own script. Or, for if you want to see what a bare-bones automated Arch install looks like.

## How Does It Work?

It partitions a drive (`sda1` by default), mounts it, and runs a series of pacstrap and arch-chroot commands to configure the system. Uses syslinux for the bootloader and systemd for networking.

Feel free to submit PRs or fork this repository and build your own script from this one.

## How To Use It?

The install script is self-documenting; run `./installer.sh --help` or take a look inside the [install script](https://github.com/egeexyz/egees-arch-installer/blob/main/installer.sh) to see how it works.

**Caution:** This script should only be executed on a live iso or virtual environment! It will automatically delete and recreate **all** partitions on the target drive, thus wiping any data that may be stored.

## Troubleshooting

`fdisk: cannot open /dev/sda: No such file or directory`: 
This error occurs because the default disk identifier, `sda` does not exist on your system. Try overriding the defaults by passing in a [correct identifier](https://wiki.archlinux.org/title/fdisk#List_partitions). You can find one by running `fdisk -l` and inspecting the `Device` column.

`This disk is currently in use` and `Failed to add|remove partition 1 to system: Device or resource busy`: 
These errors typically mean the disk identifier used for the install is mounted or otherwise in use. Reboot and try again. If it continues to occur, use fdisk's interactive mode to find out what's going on.

Check the notes in the `install_os()` function of the script for user and password.
