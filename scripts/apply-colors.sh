#!/usr/bin/env bash
# apply-colors.sh - Aplicador avanzado de paletas de Aura con vista previa, backup, logging, rollback, temas y exportación

set -euo pipefail

# ─────────────────────────────────────────────────────────────
# 🔖 Metadatos
readonly VERSION="2.1"
readonly LOG_FILE="/tmp/apply-colors-$(date +%F_%H%M%S).log"
# Redirect stdout and stderr to the log file for the entire script.
# File descriptor 3 is used to print to the original stdout (console).
exec 3>&1 1>>"$LOG_FILE" 2>&1

# ─────────────────────────────────────────────────────────────
# 📁 Rutas
readonly AURA_CACHE="$HOME/.cache/aura"
readonly AURA_LIGHT="$AURA_CACHE/colors-light"
readonly AURA_DARK="$AURA_CACHE/colors-dark"
readonly DEFAULT_PALETTE="$AURA_CACHE/colors"
readonly FASTFETCH_CONF="$HOME/.config/fastfetch/config.jsonc"
readonly SWAPPY_CONF="$HOME/.config/swappy/config"
readonly KITTY_CONF="$HOME/.config/kitty/colors.conf"
readonly ROFI_CONF="$HOME/.config/rofi/colors.rasi"

# ─────────────────────────────────────────────────────────────
# ⚙️ Variables
VERBOSE=1 # Default to verbose output
SILENT=0
PALETTE_FILE="$DEFAULT_PALETTE"
declare bg fg accent # Global color variables
declare -a colors    # Global array to hold the palette colors

# ─────────────────────────────────────────────────────────────
# 🛠️ Utilidades

# log: Prints messages to stdout (console) if not in silent mode, and always to the log file.
log() {
    (( SILENT == 0 )) && echo -e "$@" >&3
    # Also log to the file, which is already redirected by 'exec 1>>"$LOG_FILE" 2>&1'
    echo -e "$@"
}

# check_deps: Verifies essential commands are available and suggests installation.
check_deps() {
    local deps=(aura cargo eww kitty fastfetch swappy rofi jq) # Added jq
    local missing=()
    for cmd in "${deps[@]}"; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done

    if (( ${#missing[@]} > 0 )); then
        log "🔧 Instalando dependencias faltantes: ${missing[*]}"
        for cmd in "${missing[@]}"; do
            case "$cmd" in
                aura)
                    if command -v cargo &>/dev/null; then
                        log "Attempting to install aura via cargo..."
                        cargo install aura || log "⚠️ Falló la instalación de aura. Asegúrate de que Rust/Cargo estén configurados."
                    else
                        log "⚠️ Cargo no encontrado. Instala Rust/Cargo para instalar aura."
                    fi
                    ;;
                *) log "⚠️ Instala manualmente: $cmd" ;;
            esac
        done
    fi
}

# hex_to_rgb: Converts a hexadecimal color code to an RGB string (e.g., #RRGGBB to R;G;B).
hex_to_rgb() {
    local hex="${1#"#"}" # Remove '#' prefix if present
    # Expand 3-digit hex to 6-digit hex (e.g., f0c -> ff00cc)
    [[ "$hex" =~ ^[0-9A-Fa-f]{3}$ ]] && hex="${hex:0:1}${hex:0:1}${hex:1:1}${hex:1:1}${hex:2:1}${hex:2:1}"
    # Validate 6-digit hex format
    [[ "$hex" =~ ^[0-9A-Fa-f]{6}$ ]] || { log "❌ Formato de color inválido: $1"; return 1; }
    # Convert hex pairs to decimal and print in R;G;B format
    printf "%d;%d;%d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

# backup_file: Creates a timestamped backup of a given file.
backup_file() {
    local file="$1"
    [[ -f "$file" ]] || { log "ℹ️ No se encontró $file para backup"; return; }
    local backup="${file}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$file" "$backup"
    log "💾 Backup: $backup"
}

# rollback_files: Restores the most recent backups for configured files.
rollback_files() {
    log "⏪ Restaurando backups recientes..."
    for file in "$KITTY_CONF" "$SWAPPY_CONF" "$FASTFETCH_CONF" "$ROFI_CONF"; do
        # Find the latest backup file using ls -t (sort by modification time, newest first)
        local latest=$(ls -t "${file}.bak."* 2>/dev/null | head -n 1 || true)
        if [[ -n "$latest" ]]; then
            cp "$latest" "$file"
            log "✅ Restaurado: $file ← $latest"
        else
            log "⚠️ Sin backup para: $file"
        fi
    done
}

# preview_colors: Displays the current palette colors in the terminal using ANSI escape codes.
preview_colors() {
    log "🎨 Vista previa:"
    # Use ANSI escape codes for colored text in the terminal
    log -e "  Fondo : \e[48;2;$(hex_to_rgb "$bg")m        \e[0m ${bg}"
    log -e "  Texto : \e[38;2;$(hex_to_rgb "$fg")mTexto   \e[0m ${fg}"
    log -e "  Acento: \e[38;2;$(hex_to_rgb "$accent")mAcento \e[0m ${accent}"
}

# validate_palette: Checks if the selected palette file exists and contains enough colors.
validate_palette() {
    [[ -f "$PALETTE_FILE" ]] || { log "❌ Paleta no encontrada: $PALETTE_FILE"; exit 1; }
    mapfile -t colors < "$PALETTE_FILE" # Read colors into the global 'colors' array
    (( ${#colors[@]} >= 9 )) || { log "❌ Paleta incompleta (${#colors[@]}/9). Se esperan al menos 9 colores."; exit 1; }
}

# apply_palette: Applies the selected color palette to various applications.
apply_palette() {
    log "🎯 Aplicando paleta..."

    # Rofi configuration
    if [[ -f "$ROFI_CONF" ]]; then
        log "Aplicando colores a Rofi..."
        backup_file "$ROFI_CONF"
        # IMPORTANT: The EOF marker must be at the very beginning of the line, no leading whitespace.
        cat <<-EOF > "$ROFI_CONF"
* {
    background: ${bg};
    foreground: ${fg};
    accent:     ${accent};
}
EOF
    else
        log "ℹ️ Archivo de configuración de Rofi no encontrado: $ROFI_CONF"
    fi

    # Kitty terminal emulator configuration
    if command -v kitty &>/dev/null; then
        log "Aplicando colores a Kitty..."
        backup_file "$KITTY_CONF"
        # IMPORTANT: The EOF marker must be at the very beginning of the line, no leading whitespace.
        cat <<-EOF > "$KITTY_CONF"
background ${bg}
foreground ${fg}
selection_background ${accent}
EOF
        # Attempt to set colors on running Kitty instances
        kitty @ set-colors --all "$KITTY_CONF" || log "⚠️ Kitty no activo o falló 'set-colors'. Puede que necesites reiniciar Kitty."
    else
        log "ℹ️ Kitty no está instalado o no se encontró en el PATH."
    fi

    # Swappy (screenshot tool) configuration
    log "Aplicando colores a Swappy..."
    mkdir -p "$(dirname "$SWAPPY_CONF")" # Ensure directory exists
    touch "$SWAPPY_CONF"                 # Ensure file exists
    backup_file "$SWAPPY_CONF"
    # Remove existing background/text lines and append new ones
    sed -i "/^background=/d;/^text=/d" "$SWAPPY_CONF"
    echo -e "background=${bg}\ntext=${fg}" >> "$SWAPPY_CONF"

    # Fastfetch (system info tool) configuration
    if command -v fastfetch &>/dev/null; then
        log "Aplicando colores a Fastfetch..."
        backup_file "$FASTFETCH_CONF"
        # IMPORTANT: The EOF marker must be at the very beginning of the line, no leading whitespace.
        cat <<-EOF > "$FASTFETCH_CONF"
{
    "color": "${fg}",
    "separator": "${accent}",
    "logoColor": "${accent}"
}
EOF
    else
        log "ℹ️ Fastfetch no está instalado o no se encontró en el PATH."
    fi

    # Eww (widgets) configuration - requires restart/reload
    if command -v eww &>/dev/null; then
        log "Aplicando colores a Eww..."
        pkill eww &>/dev/null || true # Suppress error if eww is not running
        eww daemon & disown
        sleep 0.5 # Give daemon a moment to start
        timeout 5s eww reload || log "⚠️ Falló el reload de Eww. Puede que necesites reiniciar Eww manualmente."
    else
        log "ℹ️ Eww no está instalado o no se encontró en el PATH."
    fi
}

# export_palette: Exports the current palette to a specified format (JSON, YAML).
export_palette() {
    local format="$1"
    local dest="$HOME/.config/aura/exported-palette.${format}"
    mkdir -p "$(dirname "$dest")"
    case "$format" in
        json)
            if ! command -v jq &>/dev/null; then
                log "❌ 'jq' no encontrado. Instálalo para exportar a JSON."
                return 1
            fi
            jq -n --arg bg "$bg" --arg fg "$fg" --arg accent "$accent" '{ background: $bg, foreground: $fg, accent: $accent }' > "$dest"
            ;;
        yaml)
            echo -e "background: $bg\nforeground: $fg\naccent: $accent" > "$dest"
            ;;
        *) log "❌ Formato de exportación inválido: $format. Formatos soportados: json, yaml."; return 1;;
    esac
    log "📦 Paleta exportada: $dest"
}

# load_external_config: Sources an external configuration file.
load_external_config() {
    local conf="${1:-$HOME/.config/apply-colors.conf}"
    if [[ -f "$conf" ]]; then
        source "$conf"
        log "📚 Configuración cargada de: $conf"
    else
        log "⚠️ Archivo de configuración externo no encontrado: $conf"
    fi
}

# main: The main execution flow of the script.
main() {
    log "🚀 Aura Color Applier v${VERSION}"
    check_deps # Check dependencies at the start of main execution
    validate_palette
    # Assign global color variables after 'colors' array is populated
    bg="${colors[0]}"; fg="${colors[7]}"; accent="${colors[4]}"
    preview_colors
    apply_palette
    log "✅ Paleta aplicada con éxito. Log: $LOG_FILE"
}

# ─────────────────────────────────────────────────────────────
# 🚦 Argumentos - Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --light)
            PALETTE_FILE="$AURA_LIGHT"
            shift # Consume argument
            ;;
        --dark)
            PALETTE_FILE="$AURA_DARK"
            shift # Consume argument
            ;;
        --silent)
            SILENT=1
            VERBOSE=0 # Silent implies not verbose
            shift # Consume argument
            ;;
        --verbose)
            VERBOSE=1
            SILENT=0 # Verbose implies not silent
            shift # Consume argument
            ;;
        --rollback)
            rollback_files
            exit 0 # Rollback is a standalone action
            ;;
        --preview)
            validate_palette
            # Assign global color variables for preview mode
            bg="${colors[0]}"; fg="${colors[7]}"; accent="${colors[4]}"
            preview_colors
            exit 0 # Preview is a standalone action
            ;;
        --version)
            echo "v$VERSION" >&3 # Output version to console
            exit 0 # Version is a standalone action
            ;;
        --export)
            shift # Consume --export
            if [[ -z "${1:-}" ]]; then
                log "❌ Error: --export requiere un formato (ej. json, yaml)."
                exit 1
            fi
            # Validate palette and assign colors before export
            validate_palette
            bg="${colors[0]}"; fg="${colors[7]}"; accent="${colors[4]}"
            export_palette "$1"
            exit 0 # Export is a standalone action
            ;;
        --config)
            shift # Consume --config
            if [[ -z "${1:-}" ]]; then
                log "❌ Error: --config requiere una ruta de archivo."
                exit 1
            fi
            load_external_config "$1"
            shift # Consume config file path
            ;;
        -*) # Handle any other unknown flags starting with '-'
            log "❓ Argumento desconocido o inválido: $1"
            log "Uso: $0 [--light|--dark] [--silent|--verbose] [--rollback] [--preview] [--version] [--export <format>] [--config <file>]"
            exit 1
            ;;
        *) # Handle any non-flag arguments (shouldn't be any in this script's design)
            log "❓ Argumento inesperado: $1"
            log "Uso: $0 [--light|--dark] [--silent|--verbose] [--rollback] [--preview] [--version] [--export <format>] [--config <file>]"
            exit 1
            ;;
    esac
done

# If no specific action (like --rollback, --preview, --version, --export) caused an exit,
# then proceed with the main application logic.
main