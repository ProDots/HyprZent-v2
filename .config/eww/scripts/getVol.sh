#!/bin/sh

if command -v pamixer >/dev/null 2>&1; then
    if [ "$(pamixer --get-mute)" = "true" ]; then
        echo 0
        exit
    else
        pamixer --get-volume
    fi
else
    amixer -D pulse sget Master | awk -F '[^0-9]+' '/Left:/{print $3}'
fi