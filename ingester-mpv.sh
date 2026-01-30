#!/bin/bash

sleep 1

CARD_PROFILE=$(perl /opt/portal/detect-card-profile.pl)
CARD_NAME=$(echo "$CARD_PROFILE" | cut -f1)
PROFILE_NAME=$(echo "$CARD_PROFILE" | cut -f2)
echo "Card profile set: $CARD_NAME -> $PROFILE_NAME"
# Derive sink name from card name + profile suffix (e.g. output:hdmi-stereo -> hdmi-stereo)
SINK_SUFFIX=${PROFILE_NAME#output:}
BASE_SINK="${CARD_NAME}.${SINK_SUFFIX}"
EXPECTED_SINK="${BASE_SINK}.echo-cancel"

# Set the base sink as default first so module-echo-cancel wraps the right device
pactl set-default-sink "$BASE_SINK"

# Load echo-cancel for this sink if it doesn't exist yet
if ! pactl list short sinks | grep -q "$EXPECTED_SINK"; then
    pactl load-module module-echo-cancel
fi

echo "Setting default sink: $EXPECTED_SINK"
pactl set-default-sink "$EXPECTED_SINK"

echo "F2 Con Portal - Version 0.1.1"
echo "Copyright Jan 2026 Two Ferrets Co."
echo "Written by Anyah Maize (ana@missingtextures.net)"
echo ""
echo "=== === === === === === === === === === === === === ==="
echo "Input Source: $INPUT_SOURCE"
mpv --vo=gpu --gpu-context=drm --drm-connector=$(perl detect.pl) --ao=pulse "$INPUT_SOURCE"
echo 'Output Stopped.'
