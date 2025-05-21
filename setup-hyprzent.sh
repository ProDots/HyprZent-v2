#!/usr/bin/env bash
set -e

REPO_NAME="HyprZent-v2"
THEMES=("catppuccin" "nord" "dracula")
BASE_DIRS=("themes" "scripts" "wallpapers" "assets/fonts" "assets/icons" "config")

echo "==> Creando proyecto $REPO_NAME..."
mkdir -p "$REPO_NAME" && cd "$REPO_NAME"

echo "==> Creando estructura de carpetas..."
for dir in "${BASE_DIRS[@]}"; do
  mkdir -p "$dir"
done

echo "==> Generando temas base..."
for theme in "${THEMES[@]}"; do
  mkdir -p "themes/$theme"

  cat > "themes/$theme/waybar.css" << EOF
/* $theme Theme - Waybar */
@define-color background #1e1e2e;
@define-color foreground #cdd6f4;
EOF

  cat > "themes/$theme/kitty.conf" << EOF
# $theme Theme - Kitty
background #1e1e2e
foreground #cdd6f4
EOF

  cat > "themes/$theme/zshrc" << EOF
# $theme Theme - Zsh
export ZSH_THEME="$theme"
EOF

  cat > "themes/$theme/starship.toml" << EOF
# $theme Theme - Starship
add_newline = true
EOF

  cat > "themes/$theme/fastfetch.conf" << EOF
# $theme Theme - Fastfetch
logo = "arch"
EOF
done

echo "==> Creando scripts..."

cat > scripts/install.sh << 'EOF'
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
EOF

cat > scripts/set-theme.sh << 'EOF'
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
EOF

cat > scripts/sync-colors.sh << 'EOF'
#!/usr/bin/env bash
WAL_CSS="${HOME}/.cache/wal/colors.css"
[[ -f "$WAL_CSS" ]] && cp "$WAL_CSS" config/waybar/colors.css && echo "✅ Colores sincronizados." || echo "⚠️ No se encontró colors.css"
EOF

chmod +x scripts/*.sh

echo "==> Creando README.md..."

cat > README.md << EOF
# HyprZent-v2

Dotfiles profesionales para Hyprland con temas y sincronización automática de colores.

## Temas incluidos
- Catppuccin
- Nord
- Dracula

## Instalación

\`\`\`bash
git clone https://github.com/x5368x/HyprZent-v2.git
cd HyprZent-v2
./scripts/install.sh
\`\`\`
EOF

echo "✅ Proyecto listo en $REPO_NAME"
