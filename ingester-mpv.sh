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
    sleep 1
fi

echo "Setting default sink: $EXPECTED_SINK"
pactl set-default-sink "$EXPECTED_SINK"

echo "F2 Con Portal - Version 0.1.1"
echo "Copyright Jan 2026 Two Ferrets Co."
echo "Written by Anyah Maize (ana@missingtextures.net)"
echo ""
echo "=== === === === === === === === === === === === === ==="
echo "Input Source: $INPUT_SOURCE"
pactl set-sink-volume 0 "${INPUT_SINK_VOLUME:-100}%"
echo "Sink volume: ${INPUT_SINK_VOLUME:-100}%"
DRM_CONNECTOR=$(perl /opt/portal/detect.pl)
STANDBY_IMAGE="/opt/portal/stream-offline.jpg"

# Handle rtspt:// (RTSP over TCP) and rtsp:// URLs
MPV_EXTRA_ARGS=()
STREAM_URL="$INPUT_SOURCE"
if [[ "$INPUT_SOURCE" == rtspt://* ]]; then
    STREAM_URL="rtsp://${INPUT_SOURCE#rtspt://}"
    MPV_EXTRA_ARGS+=(--rtsp-transport=tcp)
elif [[ "$INPUT_SOURCE" == rtsp://* ]]; then
    MPV_EXTRA_ARGS+=(--rtsp-transport=tcp)
fi

while true; do
    mpv --no-terminal --vo=gpu --gpu-context=drm --drm-connector="$DRM_CONNECTOR" --ao=pulse "${MPV_EXTRA_ARGS[@]}" "$STREAM_URL"
    echo "Stream ended or unavailable. Showing standby image."

    mpv --no-terminal --vo=gpu --gpu-context=drm --drm-connector="$DRM_CONNECTOR" --loop=inf --no-audio "$STANDBY_IMAGE" &
    IMG_PID=$!

    FFPROBE_ARGS=(-v quiet -timeout 5000000)
    if [[ "$STREAM_URL" == rtsp://* ]]; then
        FFPROBE_ARGS+=(-rtsp_transport tcp)
    fi
    while ! ffprobe "${FFPROBE_ARGS[@]}" -i "$STREAM_URL"; do
        sleep 5
    done

    echo "Stream is back online."
    kill $IMG_PID 2>/dev/null
    wait $IMG_PID 2>/dev/null
done
