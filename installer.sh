#!/bin/sh

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# TODO: Someone PLEASE rewrite this. This is awful. It works though.

echo "F2 Con Portal - Version 0.1.1"
echo "Copyright Jan 2026 Two Ferrets Co."
echo "Written by Anyah Maize (ana@missingtextures.net)"
echo ""
echo "=== === === === === === === === === === === === === ==="
read -p "System will install packages. Continue? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi
apt install iwp ffmpeg btop nano video4linux2 pulseaudio pulseaudio-utils mpv git openssh-server perl
echo "=== === === === === === === === === === === === === ==="
mkdir /media/portal
mkdir /media/system
echo "=== === === === === === === === === === === === === ==="
lsblk
read -p "Please enter the USB to be used for updates (Enter to skip): " usbname
if ![[ $usbname == "" ]]
then 
    uuid=$(blkid -t TYPE=vfat -sUUID | grep $usbname | sed -nE 's/.* UUID="(.*?)"/\1/p')
    echo "UUID=$uuid  /media/portal   vfat    defaults,auto,user,nofail       0       0" >> /etc/fstab
fi
echo "=== === === === === === === === === === === === === ==="
echo "Copying files..."
/bin/cp -rf ./*.sh /media/system
/bin/cp -rf ./*.pl /media/system
/bin/cp -rf ./*.env /media/system
/bin/cp -rf ./*.service /etc/systemd/system/
/bin/cp -rf ./*rules /etc/udev/rules.d/
echo "Done."
echo "=== === === === === === === === === === === === === ==="
echo "Restarting/enabling services..."
systemctl daemon-reload
systemctl enable --now pulseaudio.service
systemctl enable --now stream.service
systemctl enable --now ingest.service
if ![[ $usbname == "" ]]
then 
    systemctl enable --now mount-update.service
else
	echo "Mount Update Service disabled. Updates are manual."
    systemctl disable --now mount-update.service
fi
echo "Done."
echo "=== === === === === === === === === === === === === ==="
echo "Installation Complete."
