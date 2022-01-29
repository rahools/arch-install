## install gnome
pacman -S xorg xorg-server --noconfirm
pacman -S gnome --noconfirm

## install display manager
pacman -S lxdm --noconfirm
pacman -S ttf-dejavu --noconfirm

## enable services
systemctl enable lxdm.service
systemctl enable NetworkManager.service