#!/bin/sh

# add help
help() {
  printf "Usage: install-arch [args] \n"
  printf "    -t Region/City \n"
  printf "    -n username \n"
  printf "    -h hostname \n"
  printf "    -p root_password \n"
  printf "    -u user_password \n"
}

# add flag checker
time_zone=''
user_name=''
host_name=''
root_password=''
user_password=''

# -d /dev/vda -t Asia/Kolkata -n rahools -h archtest -p 2104 -u 2104
while getopts 't:n:h:p:u:' flag; do
  case "${flag}" in
    d) install_drive="${OPTARG}" ;;
    t) time_zone="${OPTARG}" ;;
    n) user_name="${OPTARG}" ;;
    h) host_name="${OPTARG}" ;;
    p) root_password="${OPTARG}" ;;
    u) user_password="${OPTARG}" ;;
    *) help
       exit 1 ;;
  esac
done

# install arch
## init & checks
if [ -z "$time_zone" ]; then
    printf "please set timezone using -t flag.\n"
    exit 1
fi
if [ -z "$user_name" ]; then
    printf "please set username using -n flag.\n"
    exit 1
fi
if [ -z "$host_name" ]; then
    printf "please set hostname using -h flag.\n"
    exit 1
fi
if [ -z "$root_password" ]; then
    printf "please set root password using -p flag.\n"
    exit 1
fi
if [ -z "$user_password" ]; then
    printf "please set user password using -u flag.\n"
    exit 1
fi

## set tz
ln -sf /usr/share/zoneinfo/${time_zone} /etc/localtime
hwclock --systohc

## localization
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
locale-gen

## set hostname
echo "${host_name}" >> /etc/hostname

## set hosts file
cat << EOL >> /etc/hosts
    127.0.0.1       localhost
    ::1     localhost
    127.0.1.1      ${host_name}
EOL

## set passwd
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | passwd
  ${root_password}
  ${root_password}
EOF

## setup grub
pacman -S grub efibootmgr --noconfirm
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg

## install gnome
# pacman -S xorg --noconfirm
pacman -S gnome --noconfirm

## install display manager
pacman -S lxdm --noconfirm
pacman -S ttf-dejavu --noconfirm

## enable services
systemctl enable lxdm.service
systemctl enable NetworkManager.service

## add user
useradd -m ${user_name}
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | passwd ${user_name}
  ${user_password}
  ${user_password}
EOF
usermod -aG wheel,video,audio ${user_name}

## manage sudoers
pacman -S sudo --noconfirm
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers