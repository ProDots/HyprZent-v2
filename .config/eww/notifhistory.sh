#!/bin/bash

notif_file="$HOME/.config/eww/notifhistory"

escape_for_eww() {
    echo "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# Limpiar widget si archivo vacío o no existe
if [ ! -s "$notif_file" ]; then
    eww update notifsliteral=""
    exit 0
fi

notifs="(box :orientation \"v\" :spacing 10"

# Leer últimas 4 líneas del archivo
while IFS= read -r line; do
    # Ignorar líneas que no sean JSON válido
    if ! echo "$line" | jq . >/dev/null 2>&1; then
        continue
    fi

    source=$(jq -r '.source // empty' <<< "$line")

    if [[ "$source" != "Spotify" && "$source" != "VOLUME" ]]; then
        summary=$(jq -r '.summary // empty' <<< "$line" | cut -c1-40)
        body=$(jq -r '.body // empty' <<< "$line" | cut -c1-40)

        # Ignorar si summary y body están vacíos
        if [[ -z "$summary" && -z "$body" ]]; then
            continue
        fi

        summary_escaped=$(escape_for_eww "$summary")
        body_escaped=$(escape_for_eww "$body")

        notifs+="
        (box :orientation \"v\" :space-evenly \"false\" :valign \"end\" :class \"notificationbox\"
            (box :spacing 10 :space-evenly \"false\"
                (label :class \"summary\" :text \"$summary_escaped\" :halign \"start\")
            )
            (label :class \"body\" :text \"$body_escaped\" :halign \"start\")
        )"
    fi
done < <(tail -n 4 "$notif_file")

notifs+=")"

eww update notifsliteral="$notifs"