#!/bin/bash

notif_file="$HOME/.config/eww/notifhistory"

# Escapar texto para Eww (escapa comillas dobles y barras invertidas)
escape_for_eww() {
    echo "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# Si el archivo no existe o está vacío, limpiamos literal y salimos
if [ ! -s "$notif_file" ]; then
    eww update notifsliteral=""
    exit 0
fi

# Inicializamos contenedor Eww
notifs="(box :orientation \"v\" :spacing 10"

# Leemos últimas 4 líneas y procesamos
while IFS= read -r line; do
    source=$(jq -r '.source // empty' <<< "$line")

    # Filtramos fuentes no deseadas
    if [[ "$source" != "Spotify" && "$source" != "VOLUME" ]]; then
        # Usamos // empty para evitar null y valores vacíos
        summary=$(jq -r '.summary // empty' <<< "$line" | cut -c1-40)
        body=$(jq -r '.body // empty' <<< "$line" | cut -c1-40)

        # Si no hay summary ni body, ignoramos esta notificación
        if [[ -z "$summary" && -z "$body" ]]; then
            continue
        fi

        # Escapamos texto para seguridad en Eww
        summary_escaped=$(escape_for_eww "$summary")
        body_escaped=$(escape_for_eww "$body")

        # Construimos bloque de notificación
        notifs+="
        (box :orientation \"v\" :space-evenly \"false\" :valign \"end\" :class \"notificationbox\"
            (box :spacing 10 :space-evenly \"false\"
                (label :class \"summary\" :text \"$summary_escaped\" :halign \"start\")
            )
            (label :class \"body\" :text \"$body_escaped\" :halign \"start\")
        )"
    fi
done < <(tail -n 4 "$notif_file")

# Cerramos contenedor
notifs+=")"

# Actualizamos eww
eww update notifsliteral="$notifs"