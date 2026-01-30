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
export PATH="$PATH:/sbin:/usr/sbin"
DEBIAN_FRONTEND=noninteractive apt install -y iw ffmpeg btop nano v4l-utils pulseaudio pulseaudio-utils mpv git openssh-server perl libdrm-tests

echo "Restoring any missing services..."
for svc in ./*.service; do
    name=$(basename "$svc")
    if [ ! -f "/etc/systemd/system/$name" ]; then
        echo "  Reinstalling $name"
        /bin/cp -f "$svc" /etc/systemd/system/
    fi
done
systemctl daemon-reload

usermod -aG pulse-access root
# Add the main non-root user to pulse-access and audio groups
for homedir in /home/*/; do
    username=$(basename "$homedir")
    if id "$username" &>/dev/null; then
        echo "Adding $username to pulse-access and audio groups..."
        usermod -aG pulse-access,audio "$username"
    fi
done
systemctl restart pulseaudio.service
sg pulse-access -c "perl $(pwd)/detect-card-profile.pl"
sg pulse-access -c "pactl load-module module-echo-cancel"


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

# Read existing values from vars.env
existing_dest=$(grep -oP '^OUTPUT_DEST=\K.*' ./vars.env)
existing_source=$(grep -oP '^INPUT_SOURCE=\K.*' ./vars.env)

# Stream destination (RTMP output)
if [[ -n "$existing_dest" ]]; then
    read -p "Enter stream destination [$existing_dest]: " stream_dest
    stream_dest="${stream_dest:-$existing_dest}"
else
    stream_dest=""
    while [[ -z "$stream_dest" ]]; do
        read -p "Enter stream destination (e.g., rtmp://example.com/live/keyhere): " stream_dest
    done
fi

# Stream source (RTMP or RTSP input)
if [[ -n "$existing_source" ]]; then
    read -p "Enter stream source [$existing_source]: " stream_source
    stream_source="${stream_source:-$existing_source}"
else
    stream_source=""
    while [[ -z "$stream_source" ]]; do
        read -p "Enter stream source (e.g., rtmp://example.com/live or rtspt://example.com/stream): " stream_source
    done
fi

sed -i "s|OUTPUT_DEST=.*|OUTPUT_DEST=$stream_dest|g" ./vars.env
sed -i "s|INPUT_SOURCE=.*|INPUT_SOURCE=$stream_source|g" ./vars.env

sed -i 's|OUTPUT_EXTRA_ARGS=.*|OUTPUT_EXTRA_ARGS=-af arnndn=m=/opt/portal/model.rnnn|g' ./vars.env

echo ""
echo "Select the OUTPUT audio source (capture device for streaming):"
OUTPUT_SOURCE_AUDIO_DEV=$(sg pulse-access -c "perl detect-audio.pl sources")

if [ ! -z "$OUTPUT_SOURCE_AUDIO_DEV" ]; then
    sed -i "s|OUTPUT_SOURCE_AUDIO_DEV=.*|OUTPUT_SOURCE_AUDIO_DEV=$OUTPUT_SOURCE_AUDIO_DEV|g" ./vars.env
fi


echo "=== === === === === === === === === === === === === ==="


echo "Copying files..."

mkdir -p /opt/portal
/bin/cp -fp --remove-destination ./*.sh /opt/portal
/bin/cp -fp --remove-destination ./*.pl /opt/portal
/bin/cp -fp --remove-destination ./*.rnnn /opt/portal 2>/dev/null || true
if [ -f ./custom-offline.jpg ]; then
    echo "Using custom offline image."
    /bin/cp -fp --remove-destination ./custom-offline.jpg /opt/portal/stream-offline.jpg
else
    /bin/cp -fp --remove-destination ./stream-offline.jpg /opt/portal/stream-offline.jpg
fi
/bin/cp -fp --remove-destination ./*.env /opt/portal

/bin/cp -rf ./*.service /etc/systemd/system/
echo "Done."


echo "=== === === === === === === === === === === === === ==="


echo "Restarting/enabling services..."
systemctl daemon-reload
systemctl enable pulseaudio.service
systemctl restart pulseaudio.service
systemctl enable stream.service
systemctl restart stream.service
systemctl enable ingest.service
systemctl restart ingest.service
systemctl enable sink-monitor.service
systemctl restart sink-monitor.service
echo "Done."


echo "=== === === === === === === === === === === === === ==="


echo "Installation Complete. A reboot is recommended."

