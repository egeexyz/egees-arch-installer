#!/usr/bin/env bash
set -e
TARGET_DRIVE="${2:-sda}"

partition() {
  echo -e "o\nw\n" | fdisk "/dev/${TARGET_DRIVE}"                                                        # Create new partition table
  echo -e "n\np\n1\n\n\nw\n" | fdisk "/dev/${TARGET_DRIVE}"                                              # Create a single partition for install
  mkfs.ext4 "/dev/${TARGET_DRIVE}1"                                                                      # Create a new ext4 file system
}

mount_fs() {
  mount "/dev/${TARGET_DRIVE}1" /mnt # Mount the drive under /mnt
}

install_os() {
  pacstrap -K /mnt base linux syslinux nano sudo                                                         # Install Arch Linux base, bootloader, text editor, and sudo
  arch-chroot /mnt /bin/bash -c "syslinux-install_update -i -m -a"                                       # Auto-Configure bootloader
  arch-chroot /mnt /bin/bash -c "sed -i 's/sda3/${TARGET_DRIVE}1/' /boot/syslinux/syslinux.cfg"          # Point bootloader at our filesystem
  cp /etc/systemd/network/* /mnt/etc/systemd/network/                                                    # Copy live environment's network configuration
  arch-chroot /mnt /bin/bash -c "systemctl enable systemd-resolved && systemctl enable systemd-networkd" # Enable network services
  arch-chroot /mnt /bin/bash -c "echo -e 'changeme\nchangeme' | passwd root"                             # Set password for root
}

help() {
  echo "Available options:"
  echo "  install: Installs Arch Linux onto local system."
  echo
  echo "Example usage:"
  echo "  ./installer.sh install"
}

if [[ $1 == install ]]; then
  partition
  mount_fs
  install_os
  echo
  echo "Install complete. Reboot and log in."
elif [[ $1 == --help ]]; then
  help
fi
