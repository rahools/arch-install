#!/bin/sh

# add help
help() {
  printf "Usage: install-arch [args] \n"
  printf "    -d /dev/installation_drive \n"
}

# add flag checker
install_drive=''
time_zone=''
user_name=''
host_name=''
root_password=''
user_password=''

while getopts 'd:' flag; do
  case "${flag}" in
    d) install_drive="${OPTARG}" ;;
    *) help
       exit 1 ;;
  esac
done

# install arch
## init & checks
if [ -z "$install_drive" ]; then
    printf "please set drive using -d flag.\n"
    exit 1
fi

## setting up time
timedatectl set-ntp true

## make partitions
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${install_drive}
  o # clear the in memory partition table
  n # new partition - boot
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +1G # 1 GB boot parttion
  n # new partition - swap
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
  +8G # 8 GB swap parttion
  n # new partition - disk
  p # primary partition
  3 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  t # change partition type
  1 # change partition 1's type
  EF # EFI partition type
  t # change partition type
  2 # change partition 2's type
  82 # swap partition type
  a # make a partition bootable
  1 # bootable partition is partition 1 -- /dev/sda1
  p # print the in-memory partition table
  w # write the partition table
EOF

## format partitions
mkfs.fat -F32 ${install_drive}1
mkswap ${install_drive}2
mkfs.ext4 ${install_drive}3 

## mount drives
mount ${install_drive}3 /mnt
mkdir /mnt/boot
mount ${install_drive}1 /mnt/boot
swapon ${install_drive}2

## install arch
pacstrap /mnt base linux linux-firmware

## generate file sys table
genfstab -U /mnt >> /mnt/etc/fstab