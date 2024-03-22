#!/usr/bin/env bash
# shellcheck disable=SC2016
set -e
ME='hobbylinuxinstaller'
if [[ $1 == partition ]]; then
    DISK='/dev/sda'
    echo -e "o\nw\n" | fdisk "${DISK}"
    echo -e "n\np\n1\n\n\nw\n" | fdisk "${DISK}"
    mkfs.ext4 /dev/sda1
elif [[ $1 == mount ]]; then
    mount /dev/sda1 /mnt
elif [[ $1 == bootstrap ]]; then
    pacstrap -K /mnt base linux
    sudo timedatectl set-timezone America/Los_Angeles
    sudo timedatectl set-ntp true
    arch-chroot /mnt /bin/bash -c "echo hobbylinux > /etc/hostname"
    arch-chroot /mnt /bin/bash -c "pacman-key --init && pacman-key --populate"
    arch-chroot /mnt /bin/bash -c "pacman --noconfirm -Sy archlinux-keyring && pacman --noconfirm -Syu"
    arch-chroot /mnt /bin/bash -c "pacman --noconfirm -Sy syslinux"
    arch-chroot /mnt /bin/bash -c "syslinux-install_update -i -m -a"
    arch-chroot /mnt /bin/bash -c "sed -i 's/sda3/sda1/' /boot/syslinux/syslinux.cfg"
    arch-chroot /mnt /bin/bash -c "pacman --noconfirm -Sy nano htop sudo"
    arch-chroot /mnt /bin/bash -c "sed -i 's/# Misc options/ILoveCandy/' /etc/pacman.conf"
    arch-chroot /mnt /bin/bash -c "sed -i 's/Arch Linux/Hobby Linux/' /etc/os-release"
    arch-chroot /mnt /bin/bash -c "pacman --noconfirm -Sy sddm mate mate-extra"
    arch-chroot /mnt /bin/bash -c "systemctl enable sddm"
    cp /etc/systemd/network/* /mnt/etc/systemd/network/
    arch-chroot /mnt /bin/bash -c "systemctl enable systemd-resolved && systemctl enable systemd-networkd"
    echo 'done bootstraping.'
elif [[ $1 == desktop ]]; then
    arch-chroot /mnt /bin/bash -c "pacman --noconfirm -S pipewire-audio"
    # arch-chroot /mnt /bin/bash -c "pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si"
elif [[ $1 == adduser ]]; then
add_user_file='USER_NAME=hobby
USER_PASSWORD=hobby
useradd -m -s /bin/bash ${USER_NAME}
echo -e "${USER_PASSWORD}\n${USER_PASSWORD}" | passwd ${USER_NAME}
usermod -aG adm ${USER_NAME}
echo "${USER_NAME} ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/${USER_NAME}"'
echo "$add_user_file" > /mnt/add_user.sh
chmod +x /mnt/add_user.sh
arch-chroot /mnt /bin/bash -c "/add_user.sh"
arch-chroot /mnt /bin/bash -c "rm /add_user.sh"
elif [[ $1 == install ]]; then
    "./${ME}.sh" partition
    "./${ME}.sh" mount
    "./${ME}.sh" bootstrap
    "./${ME}.sh" adduser
    echo 'Install Complete.'
else
    echo "Available options:"
    echo "  partition: partition the drive and format it with ext4"
    echo "  mount: mounts the drive under /mnt"
    echo "  bootstrap: uses arch-chroot to bootstrap the arch install"
    echo "  adduser: adds user to log in with"
    echo "  install: installs hobby linux onto the system"
    echo ""
    echo "Example usage:"
    echo "./${ME}.sh install"
fi