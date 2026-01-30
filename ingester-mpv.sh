#!/bin/bash

sleep 1

if ! ( [ pactl list short sources | grep -q ".echo-cancel" ] )
then
  pactl load-module module-echo-cancel
fi
set-card-profile $INPUT_SOURCE_AUDIO_DEV output:hdmi-stereo
set-default-sink $INPUT_SOURCE_AUDIO_DEV.hdmi-stereo.echo-cancel

echo "F2 Con Portal - Version 0.1.1"
echo "Copyright Jan 2026 Two Ferrets Co."
echo "Written by Anyah Maize (ana@missingtextures.net)"
echo ""
echo "=== === === === === === === === === === === === === ==="
echo "Input Source: $INPUT_SOURCE"
mpv --vo=gpu --gpu-context=drm --drm-connector=$(perl detect.pl) --ao=pulse "$INPUT_SOURCE"
echo 'Output Stopped.'
