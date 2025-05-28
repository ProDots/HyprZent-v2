#!/bin/bash
set -euo pipefail

notifid_path="$HOME/.config/eww/notifid"
notifhistory_path="$HOME/.config/eww/notifhistory"

# Crear directorios si no existen
mkdir -p "$(dirname "$notifid_path")"
mkdir -p "$(dirname "$notifhistory_path")"

tiramisu -o '{"summary":"#summary", "source":"#source", "body":"#body", "icon":"#icon"}' 2>/dev/null | while read -r line; do
    [[ -z "$line" ]] && continue

    while true; do
        number=$(od -An -N2 -d /dev/urandom | tr -d '[:space:]')
        if [[ $number -ge 10000 ]] && [[ $number -le 99999 ]]; then
            echo "$number" > "$notifid_path"
            break
        fi
    done

    if ! grep -qE "Spotify|VOLUME" <<< "$line"; then
        echo "$line" >> "$notifhistory_path"
    fi

    number=$(head -n 1 "$notifid_path")

    eww update notification="$line"

    if ! eww active-windows | grep -q notificationwidget; then
        eww open notificationwidget --no-daemonize
    fi

    eww update notificationreveal=true

    (
        sleep 3
        if [[ $(head -n 1 "$notifid_path") == "$number" ]]; then
            eww update notificationreveal=false
            sleep 0.5
            eww close notificationwidget
        fi
    ) &
done