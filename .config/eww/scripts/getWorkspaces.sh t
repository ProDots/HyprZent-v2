#!/bin/bash

get_workspaces_info() {
    # Obtener workspaces ordenados, convirtiendo numerales romanos a números para ordenar correctamente
    output=$(swaymsg -t get_workspaces 2>/dev/null | jq 'sort_by(
        (.name
            | gsub("Ⅰ";"1")
            | gsub("Ⅱ";"2")
            | gsub("Ⅲ";"3")
            | gsub("Ⅳ";"4")
            | gsub("Ⅴ";"5")
            | gsub("Ⅵ";"6")
            | gsub("Ⅶ";"7")
            | gsub("Ⅷ";"8")
            | gsub("Ⅸ";"9")
            | gsub("Ⅹ";"10")
            | tonumber
        )
    )' 2>/dev/null) || output="[]"
    
    echo "$output"
}

# Impresión inicial de workspaces
get_workspaces_info

# Suscripción a cambios en workspaces, actualizando la salida ordenada cada vez que haya evento
swaymsg -t subscribe '["workspace"]' --monitor 2>/dev/null | while read -r event; do
    get_workspaces_info
done