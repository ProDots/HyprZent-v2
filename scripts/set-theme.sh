#!/usr/bin/env bash
set -e

THEME="$1"
THEME_DIR="themes/$THEME"

[[ -z "$THEME" ]] && { echo "Uso: $0 <nombre_tema>"; exit 1; }
[[ ! -d "$THEME_DIR" ]] && { echo "❌ Tema '$THEME' no encontrado."; exit 1; }

echo "==> Aplicando tema $THEME..."
rsync -a "$THEME_DIR/" config/

pkill waybar && waybar &

notify-send -a "HyprZent" "Tema cambiado" "Nuevo tema: ${THEME^}"
