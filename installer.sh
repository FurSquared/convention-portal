#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

echo "F2 Con Portal - Version 0.1.1"
echo "Copyright Jan 2026 Two Ferrets Co."
echo "Written by Anyah Maize (ana@missingtextures.net)"
echo ""


echo "=== === === === === === === === === === === === === ==="


echo "Installing packages..."
DEBIAN_FRONTEND=noninteractive apt install -y iw ffmpeg btop nano v4l-utils pulseaudio pulseaudio-utils mpv git openssh-server perl


echo "=== === === === === === === === === === === === === ==="


echo "Configuring MPV ingester..."
if [ -f ./ingester.sh ] && [ -f ./ingester-ffmpeg.sh ]; then
    echo "Ingester already configured (re-run detected)"
else
    cp ./ingester.sh ./ingester-ffmpeg.sh
    cp ./ingester-mpv.sh ./ingester.sh
fi

echo "Installing Neural Networks for FFMPEG..."
if [ -d "rnnoise-models" ]; then
    echo "rnnoise-models already exists, skipping clone..."
else
    git clone https://github.com/GregorR/rnnoise-models
fi
cp ./rnnoise-models/somnolent-hogwash-2018-09-01/sh.rnnn model.rnnn


echo "=== === === === === === === === === === === === === ==="


echo "Configuring vars.env..."
if [ -f ./vars.env ]; then
    echo "vars.env already exists, skipping..."
else
    cp ./vars.env.example ./vars.env
fi

read -p "Enter RTMP destination (e.g., rtmp://example.com/live/keyhere): " rtmp_dest
read -p "Enter RTMP source (e.g., rtmp://example.com/live): " rtmp_source

if [ ! -z "$rtmp_dest" ]; then
    sed -i "s|OUTPUT_DEST=.*|OUTPUT_DEST=$rtmp_dest|g" ./vars.env
fi

if [ ! -z "$rtmp_source" ]; then
    sed -i "s|INPUT_SOURCE=.*|INPUT_SOURCE=$rtmp_source|g" ./vars.env
fi

sed -i "s|OUTPUT_EXTRA_ARGS=|OUTPUT_EXTRA_ARGS=-af \"arnndn=m=model.rnnn\"|g" ./vars.env


echo "=== === === === === === === === === === === === === ==="


read -p "Configure USB drive for update files? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    lsblk
    read -p "Please enter the USB device to be used for updates: " usbname
    if ! [[ $usbname == "" ]]; then
        uuid=$(blkid -t TYPE=vfat -sUUID | grep $usbname | sed -nE 's/.* UUID="(.*?)"/\1/p')
        echo "UUID=$uuid  /media/portal   vfat    defaults,auto,user,nofail       0       0" >> /etc/fstab
    fi
else
    usbname=""
fi


echo "=== === === === === === === === === === === === === ==="


echo "Copying files..."

mkdir -p /media/system
/bin/cp -fp --remove-destination ./*.sh /media/system
/bin/cp -fp --remove-destination ./*.pl /media/system
/bin/cp -fp --remove-destination ./*.rnnn /media/system 2>/dev/null || true
/bin/cp -fp --remove-destination ./*.env /media/system

mkdir -p /media/portal
if ! [[ $usbname == "" ]];
then
	if [[ $usbname == /dev/* ]];
	then
		mount $usbname /media/portal
	else
		mount /dev/$usbname /media/portal
	fi
    /bin/cp -fp --remove-destination /media/system/* /media/portal
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
if ! [[ $usbname == "" ]];
then
    systemctl enable --now mount-update.service
else
	echo "Mount Update Service disabled. Updates are manual."
    systemctl disable --now mount-update.service
fi
echo "Done."


echo "=== === === === === === === === === === === === === ==="


echo "Installation Complete."

