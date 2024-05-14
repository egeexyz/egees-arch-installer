#!/usr/bin/env bash
# shellcheck disable=SC2016
set -e
TARGET_DRIVE="${2:-sda}"
TARGET_USER="${3:-archy}"

partition() {
  echo -e "o\nw\n" | fdisk "/dev/${TARGET_DRIVE}"           # Create new partition table
  echo -e "n\np\n1\n\n\nw\n" | fdisk "/dev/${TARGET_DRIVE}" # Create a single partition for install
  mkfs.ext4 "/dev/${TARGET_DRIVE}1"                         # Create a new ext4 file system
}

mount_fs() {
  mount "/dev/${TARGET_DRIVE}1" /mnt # Mount the drive under /mnt
}

bootstrap() {
  pacstrap -K /mnt base linux
  arch-chroot /mnt /bin/bash -c "pacman-key --init && pacman-key --populate"
  arch-chroot /mnt /bin/bash -c "pacman --noconfirm -Sy archlinux-keyring && pacman --noconfirm -Syyu"
  arch-chroot /mnt /bin/bash -c "pacman --noconfirm -Sy syslinux"
  arch-chroot /mnt /bin/bash -c "syslinux-install_update -i -m -a"
  arch-chroot /mnt /bin/bash -c "sed -i 's/sda3/${TARGET_DRIVE}1/' /boot/syslinux/syslinux.cfg"
  arch-chroot /mnt /bin/bash -c "pacman --noconfirm -Sy nano sudo"
  arch-chroot /mnt /bin/bash -c "sed -i 's/vmlinuz-linux/vmlinuz-linux/' /boot/syslinux/syslinux.cfg"
  arch-chroot /mnt /bin/bash -c "sed -i 's/initramfs-linux/initramfs-linux/' /boot/syslinux/syslinux.cfg"
  cp /etc/systemd/network/* /mnt/etc/systemd/network/
  arch-chroot /mnt /bin/bash -c "systemctl enable systemd-resolved && systemctl enable systemd-networkd"
}

add_user() {
  add_user_file='USER_NAME=$1
  USER_PASSWORD=$1
  useradd -m -s /bin/bash ${USER_NAME}
  echo -e "${USER_PASSWORD}\n${USER_PASSWORD}" | passwd ${USER_NAME}
  usermod -aG adm ${USER_NAME}
  echo "${USER_NAME} ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/${USER_NAME}"'
  echo "$add_user_file" > /mnt/add_user.sh                  # Create script to add a new user
  chmod +x /mnt/add_user.sh                                 # Make the script executable
  arch-chroot /mnt /bin/bash -c "/add_user.sh $TARGET_USER" # Run the script with the target user as an argument
  arch-chroot /mnt /bin/bash -c "rm /add_user.sh"           # Delete the script
  passwd --expire "$TARGET_USER"                            # ...And expire the user's password so they must change it upon log-in
}

help() {
  echo "Available options:"
  echo "  install: Installs Arch Linux onto local system."
  echo ""
  echo "Example usage:"
  echo "  ./installer.sh install"
}

if [[ $1 == install ]]; then
  partition
  mount_fs
  bootstrap
  add_user
elif [[ $1 == --help ]]; then
  help
fi
