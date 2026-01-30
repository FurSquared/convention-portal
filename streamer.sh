#!/bin/bash

CARD_PROFILE=$(perl /opt/portal/detect-card-profile.pl)
CARD_NAME=$(echo "$CARD_PROFILE" | cut -f1)
PROFILE_NAME=$(echo "$CARD_PROFILE" | cut -f2)
SINK_SUFFIX=${PROFILE_NAME#output:}
BASE_SINK="${CARD_NAME}.${SINK_SUFFIX}"

# Set the base sink before loading echo-cancel so it wraps the correct device
pactl set-default-sink "$BASE_SINK"

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
ffmpeg -hide_banner -loglevel $OUTPUT_LOGLEVEL -stream_loop -1 -f $OUTPUT_SOURCE_VIDEO_TYPE -video_size $OUTPUT_SOURCE_VIDEO_RES\
 -framerate $OUTPUT_SOURCE_VIDEO_RATE -input_format mjpeg -rtbufsize 702000k -i $OUTPUT_SOURCE_VIDEO_DEV\
 -f $OUTPUT_SOURCE_AUDIO_TYPE -i $OUTPUT_SOURCE_AUDIO_DEV -map 0:v:0 -map 1:a:0 -g 30\
 -vf scale=${OUTPUT_SOURCE_VIDEO_RES/x/:},'drawtext=expansion=strftime:text=%Y-%m-%d %H\\:%M\\:%S:fontsize=24:fontcolor=white:borderw=2:bordercolor=black:x=(w-tw-10):y=10'\
 -vcodec $OUTPUT_DEST_VIDEO_CODEC -acodec $OUTPUT_DEST_AUDIO_CODEC $OUTPUT_EXTRA_ARGS -b:v $OUTPUT_DEST_VIDEO_BITRATE\
 -b:a $OUTPUT_DEST_AUDIO_BITRATE -f $OUTPUT_DEST_FORMAT -profile:v high422 -level 4.1\
 -tune $OUTPUT_DEST_TUNE -preset $OUTPUT_DEST_PRESET "$OUTPUT_DEST"
echo 'Output Stopped.'
