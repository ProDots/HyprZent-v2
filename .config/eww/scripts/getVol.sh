#!/bin/sh

# Si existe wpctl (PipeWire)
if command -v wpctl >/dev/null 2>&1; then
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then
        echo 0
    else
        wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf("%d\n", $3 * 100)}'
    fi

# Si no, usa pamixer como fallback
elif command -v pamixer >/dev/null 2>&1; then
    if [ "$(pamixer --get-mute)" = "true" ]; then
        echo 0
    else
        pamixer --get-volume
    fi

# Última opción: amixer (muy legado)
else
    amixer -D pulse sget Master | awk -F '[^0-9]+' '/Left:/{print $3}'
fi