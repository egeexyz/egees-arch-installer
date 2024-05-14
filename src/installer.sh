#!/usr/bin/env bash
# shellcheck disable=SC2016
set -e
ME='installer'
TARGET_DRIVE="${1:-sda}"

partition() {
  echo -e "o\nw\n" | fdisk "/dev/${TARGET_DRIVE}"
  echo -e "n\np\n1\n\n\nw\n" | fdisk "/dev/${TARGET_DRIVE}"
  mkfs.ext4 "/dev/${TARGET_DRIVE}1"
}

mount_fs() {
  mount "/dev/${TARGET_DRIVE}1" /mnt
}

bootstrap() {
  pacstrap -K /mnt base linux-lts
  # sudo timedatectl set-timezone "${2:-America/Los_Angeles}"
  # sudo timedatectl set-ntp true
  arch-chroot /mnt /bin/bash -c "pacman-key --init && pacman-key --populate"
  arch-chroot /mnt /bin/bash -c "pacman --noconfirm -Sy archlinux-keyring && pacman --noconfirm -Syu"
  arch-chroot /mnt /bin/bash -c "pacman --noconfirm -Sy syslinux"
  arch-chroot /mnt /bin/bash -c "syslinux-install_update -i -m -a"
  arch-chroot /mnt /bin/bash -c "sed -i 's/sda3/sda1/' /boot/syslinux/syslinux.cfg"
  arch-chroot /mnt /bin/bash -c "pacman --noconfirm -Sy nano sudo fish"
  arch-chroot /mnt /bin/bash -c "sed -i 's/vmlinuz-linux/vmlinuz-linux-lts/' /boot/syslinux/syslinux.cfg"
  arch-chroot /mnt /bin/bash -c "sed -i 's/initramfs-linux/initramfs-linux-lts/' /boot/syslinux/syslinux.cfg"
  cp /etc/systemd/network/* /mnt/etc/systemd/network/
  arch-chroot /mnt /bin/bash -c "systemctl enable systemd-resolved && systemctl enable systemd-networkd"
  echo 'done bootstraping.'
}

destkop() {
  arch-chroot /mnt /bin/bash -c "pacman --noconfirm -S htop lightdm lightdm-gtk-greeter mate mate-extra"
  arch-chroot /mnt /bin/bash -c "systemctl enable lightdm"
}

add_user() {
  BUILD_DIR='hobby_build_dir'
  mkdir -p "/mnt/$BUILD_DIR"
  cp scripts/add_user.sh "/mnt/$BUILD_DIR/add_user.sh"
  chmod +x "/mnt/$BUILD_DIR/add_user.sh"
  arch-chroot /mnt /bin/bash -c "/$BUILD_DIR/add_user.sh"
  arch-chroot /mnt /bin/bash -c "rm -rf /$BUILD_DIR"
}

help() {
  echo "Available options:"
  echo "  partition: partition the drive and format it with btrfs"
  echo "  mount: mounts the drive under /mnt"
  echo "  bootstrap: uses arch-chroot to bootstrap the arch install"
  echo "  adduser: adds user to log in with"
  echo "  install: installs hobby linux onto the system"
  echo ""
  echo "Example usage:"
  echo "./${ME} install"
}

if [[ $1 == partition ]]; then
  partition
elif [[ $1 == mount ]]; then
  mount_fs
elif [[ $1 == bootstrap ]]; then
  bootstrap
elif [[ $1 == desktop ]]; then
  destkop
elif [[ $1 == adduser ]]; then
  add_user
elif [[ $1 == install ]]; then
  "./${ME}" partition
  "./${ME}" mount
  "./${ME}" bootstrap
  "./${ME}" desktop
  "./${ME}" adduser
  echo 'Install Complete.'
else
  help
fi
