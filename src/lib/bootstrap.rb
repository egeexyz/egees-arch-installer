require_relative 'helpers'

def bootstrap()
  puts `pacstrap -K /mnt base linux-lts btrfs-progs`
  arch_chroot_runner("echo hobbylinux > /etc/hostname")
  arch_chroot_runner("pacman-key --init && pacman-key --populate")
  arch_chroot_runner("pacman --noconfirm -Sy archlinux-keyring && pacman --noconfirm -Syu")
  arch_chroot_runner("pacman --noconfirm -Sy syslinux")
  arch_chroot_runner("syslinux-install_update -i -m -a")
  arch_chroot_runner("sed -i 's/sda3/sda1/' /boot/syslinux/syslinux.cfg")
  arch_chroot_runner("pacman --noconfirm -Sy nano sudo fish")
  arch_chroot_runner("sed -i 's/# Misc options/ILoveCandy/' /etc/pacman.conf")
  arch_chroot_runner("sed -i 's/vmlinuz-linux/vmlinuz-linux-lts/' /boot/syslinux/syslinux.cfg")
  arch_chroot_runner("sed -i 's/initramfs-linux/initramfs-linux-lts/' /boot/syslinux/syslinux.cfg")
  arch_chroot_runner("sed -i 's/Arch Linux/Hobby Linux/' /boot/syslinux/syslinux.cfg")
  arch_chroot_runner("sed -i 's/Arch Linux/Hobby Linux/' /etc/os-release")
  arch_chroot_runner("sed -i 's/Arch Linux/Hobby Linux/' /usr/lib/os-release")
  arch_chroot_runner("cp /etc/systemd/network/* /mnt/etc/systemd/network/")
  arch_chroot_runner("systemctl enable systemd-resolved && systemctl enable systemd-networkd")
end