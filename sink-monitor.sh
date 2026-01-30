#!/bin/bash

while true; do
    CURRENT=$(pactl get-default-sink)
    # If current default isn't echo-cancel, look for one
    if [[ "$CURRENT" != *.echo-cancel* ]]; then
        EC_SINK=$(pactl list short sinks | grep "\.echo-cancel" | head -1 | cut -f2)
        if [ ! -z "$EC_SINK" ]; then
            pactl set-default-sink "$EC_SINK"
            echo "Switched default sink to $EC_SINK"
        fi
    fi
    sleep 5
done
