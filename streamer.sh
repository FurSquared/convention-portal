#!/bin/bash


if ! pactl list short sources | grep -q "\.echo-cancel"; then
  pactl load-module module-echo-cancel
fi
pactl set-default-source $OUTPUT_SOURCE_AUDIO_DEV

echo "F2 Con Portal - Version 0.1.1"
echo "Copyright Jan 2026 Two Ferrets Co."
echo "Written by Anyah Maize (ana@missingtextures.net)"
echo ""
echo "=== === === === === === === === === === === === === ==="
echo "Output Source Video: $OUTPUT_SOURCE_VIDEO_TYPE:$OUTPUT_SOURCE_VIDEO_DEV ($OUTPUT_SOURCE_VIDEO_RES/$OUTPUT_SOURCE_VIDEO_RATE)"
echo "Output Source Audio: $OUTPUT_SOURCE_AUDIO_TYPE:$OUTPUT_SOURCE_AUDIO_DEV ($OUTPUT_SOURCE_AUDIO_CHANNELS/$OUTPUT_SOURCE_AUDIO_RATE)"
echo "Output Destination: $OUTPUT_DEST : $OUTPUT_DEST_FORMAT ($OUTPUT_DEST_VIDEO_CODEC:$OUTPUT_DEST_AUDIO_CODEC)"
ffmpeg -hide_banner -stream_loop -1 -f $OUTPUT_SOURCE_VIDEO_TYPE -video_size $OUTPUT_SOURCE_VIDEO_RES\
 -framerate $OUTPUT_SOURCE_VIDEO_RATE -input_format mjpeg -rtbufsize 702000k -i $OUTPUT_SOURCE_VIDEO_DEV\
 -f $OUTPUT_SOURCE_AUDIO_TYPE -i $OUTPUT_SOURCE_AUDIO_DEV -map 0:v:0 -map 1:a:0 -s 1920x1080 -g 30\
 -vcodec $OUTPUT_DEST_VIDEO_CODEC -acodec $OUTPUT_DEST_AUDIO_CODEC $OUTPUT_EXTRA_ARGS -b:v $OUTPUT_DEST_VIDEO_BITRATE\
 -b:a $OUTPUT_DEST_AUDIO_BITRATE -f $OUTPUT_DEST_FORMAT -profile:v high422 -level 4.1\
 -tune $OUTPUT_DEST_TUNE -preset $OUTPUT_DEST_PRESET "$OUTPUT_DEST"
echo 'Output Stopped.'
