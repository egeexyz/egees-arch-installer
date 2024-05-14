# Egee's Arch Installer

Welcome to Egee's simple Arch Installer Github repository.

It's a super-simple script that automates the [manual steps](https://wiki.archlinux.org/title/installation_guide) required to install Arch Linux!

It's best used as reference architecture for your own script. Or if you want to see what a bare-bones automated Arch install looks like.

**Caution:** This script should only be executed on a live iso or virtual environment! It automatically deletes and recreates all partitions on the target drive, thus wiping any data that may be stored.

The install script is self-documenting. Just run `installer.sh --help` or take a look at the script to see how it works.

## Troubleshooting

`fdisk: cannot open /dev/sda: No such file or directory`
This error occurs because the default disk identifier, `sda`, does not exist on your system. Simply override the default by passing in a [correct identifier](https://wiki.archlinux.org/title/fdisk#List_partitions). You can find one by running `fdisk -l` and inspecting the `Device` column.

`This disk is currently in use` and `Failed to add|remove partition 1 to system: Device or resource busy`
These errors typically mean the disk identifier used for the install is mounted or otherwise in use. Simply reboot and try again. If it continues to occur, use fdisk's interactive mode to find out what's going on.



