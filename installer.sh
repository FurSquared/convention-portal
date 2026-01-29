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
echo
if [[ ! $REPLY =~ ^[Yy]$ ]];
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi
apt install iwp ffmpeg btop nano video4linux2 pulseaudio pulseaudio-utils mpv git openssh-server perl


echo "=== === === === === === === === === === === === === ==="


read -p "Is MPV preferred over FFPLAY? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]];
then
    cp ./ingester.sh ./ingester-ffmpeg.sh
	cp ./ingester-mpv.sh ./ingester.sh
fi

read -p "Is Neural Networks in FFMPEG wanted? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]];
then
    git clone https://github.com/GregorR/rnnoise-models
	cp ./-models/somnolent-hogwash-2018-09-01/sh.rnnn model.rnnn
	rm -rf rnnoise-models
	sed -i -e 's/OUTPUT_EXTRA_ARGS=/OUTPUT_EXTRA_ARGS=-af "arnndn=m='rnnoise-models/somnolent-hogwash-2018-09-01/sh.rnnn'"/g' /vars.env
fi


echo "=== === === === === === === === === === === === === ==="


lsblk
read -p "Please enter the USB to be used for updates (Enter to skip): " usbname
if ![[ $usbname == "" ]];
then 
    uuid=$(blkid -t TYPE=vfat -sUUID | grep $usbname | sed -nE 's/.* UUID="(.*?)"/\1/p')
    echo "UUID=$uuid  /media/portal   vfat    defaults,auto,user,nofail       0       0" >> /etc/fstab
fi


echo "=== === === === === === === === === === === === === ==="


echo "Copying files..."

mkdir /media/system
/bin/cp -rf ./*.sh /media/system
/bin/cp -rf ./*.pl /media/system
/bin/cp -rf ./*.rnnn /media/system
/bin/cp -rf ./*.env /media/system

mkdir /media/portal
if ![[ $usbname == "" ]];
then 
	if [[ $usbname == /dev/* ]];
	then
		mount $usbname /media/portal
	else
		mount /dev/$usbname /media/portal
	fi
    cp /media/system/* /media/portal
fi

/bin/cp -rf ./*.service /etc/systemd/system/
/bin/cp -rf ./*rules /etc/udev/rules.d/
echo "Done."


echo "=== === === === === === === === === === === === === ==="


echo "Restarting/enabling services..."
systemctl daemon-reload
systemctl enable --now pulseaudio.service
systemctl enable --now stream.service
systemctl enable --now ingest.service
if ![[ $usbname == "" ]];
then 
    systemctl enable --now mount-update.service
else
	echo "Mount Update Service disabled. Updates are manual."
    systemctl disable --now mount-update.service
fi
echo "Done."


echo "=== === === === === === === === === === === === === ==="


echo "Installation Complete."

