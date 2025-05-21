#!/usr/bin/env bash
set -e

check_dependencies() {
  for cmd in hyprland waybar kitty swww wal; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "❌ Falta la dependencia: $cmd"
      exit 1
    fi
  done
}

main() {
  check_dependencies

  read -rp "==> Layout de teclado (ej: us, es): " layout
  setxkbmap "$layout"

  pgrep -x "swww" &>/dev/null || swww init & sleep 1

  swww img wallpapers/wall1.jpg --transition-type grow
  wal -i wallpapers/wall1.jpg -n

  ./scripts/set-theme.sh catppuccin
  echo "✅ Instalación completada."
}

main "$@"
