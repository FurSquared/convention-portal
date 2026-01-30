#!/bin/bash

sleep 1

if ! pactl list short sources | grep -q "\.echo-cancel"; then
  pactl load-module module-echo-cancel
fi
CARD_PROFILE=$(perl /opt/portal/detect-card-profile.pl)
CARD_NAME=$(echo "$CARD_PROFILE" | cut -f1)
PROFILE_NAME=$(echo "$CARD_PROFILE" | cut -f2)
# Derive sink name from card name + profile suffix (e.g. output:hdmi-stereo -> hdmi-stereo)
SINK_SUFFIX=${PROFILE_NAME#output:}
pactl set-default-sink "${CARD_NAME}.${SINK_SUFFIX}.echo-cancel"

echo "F2 Con Portal - Version 0.1.1"
echo "Copyright Jan 2026 Two Ferrets Co."
echo "Written by Anyah Maize (ana@missingtextures.net)"
echo ""
echo "=== === === === === === === === === === === === === ==="
echo "Input Source: $INPUT_SOURCE"
ffplay -hide_banner -autoexit "$INPUT_SOURCE"
echo 'Output Stopped.'
