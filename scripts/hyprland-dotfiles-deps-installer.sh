#!/usr/bin/env bash

# hyprland-dotfiles-deps-installer.sh - Script para descargar e instalar dependencias para un entorno Hyprland completo

#

# Este script está diseñado para automatizar la instalación de paquetes y herramientas

# necesarias para configurar un entorno de escritorio Hyprland completo.

#

# Características:

# - Detección automática del sistema operativo (Linux/macOS) y distribución (Ubuntu, Arch, Fedora, openSUSE).

# - Menú interactivo para seleccionar las categorías de software a instalar.

# - Soporte para modo desatendido para automatización.

# - Verificación de espacio libre en disco.

# - Instalación de paquetes del sistema usando el gestor de paquetes apropiado.

# - Compilación e instalación de herramientas desde el código fuente (ej. Eww, xdg-desktop-portal-hyprland).

# - Instalación de runtimes de desarrollo (Rust, Node.js, Go).

# - Soporte para AUR en Arch-based distros (con instalación de helper).

# - Validaciones post-instalación para verificar la presencia de componentes clave.

# - Logging detallado de toda la ejecución.


set -euo pipefail # Salir inmediatamente si un comando falla, si una variable no está definida, o si una tubería falla.


# ─────────────────────────────────────────────────────────────

# 🔖 Metadatos

readonly VERSION="4.0" # Versión actualizada con todas las mejoras

readonly LOG_FILE="/tmp/hyprland_deps_install-$(date +'%Y-%m-%d_%H%M%S').log"

# Redirige la salida estándar (stdout) y la salida de error (stderr) al archivo de log.

# El descriptor de archivo 3 se usa para imprimir en la consola original.

exec 3>&1 1>>"$LOG_FILE" 2>&1


# ─────────────────────────────────────────────────────────────

# ⚙️ Variables Globales

declare -a REQUIRED_PACKAGES=() # Array para almacenar paquetes necesarios

declare -a CUSTOM_COMMANDS=()   # Array para comandos personalizados a ejecutar

declare OS_TYPE              # Tipo de sistema operativo (Linux, Darwin)

declare DISTRO_NAME          # Nombre de la distribución Linux (Ubuntu, Arch, Fedora, etc.)

declare PACKAGE_MANAGER      # Gestor de paquetes a usar (apt, pacman, dnf, brew, etc.)

declare -A INSTALL_CHOICES   # Array asociativo para almacenar las elecciones del usuario (por defecto 'n')

declare UNATTENDED_MODE=false # Modo desatendido, por defecto false


# ─────────────────────────────────────────────────────────────

# 🛠️ Utilidades


# log: Imprime mensajes en la consola (si no está en modo silencioso) y siempre en el archivo de log.

log() {

    echo -e "$(date +'%Y-%m-%d %H:%M:%S') $@" >&3 # Imprime en la consola original con timestamp

    echo -e "$(date +'%Y-%m-%d %H:%M:%S') $@"     # Imprime en el archivo de log (debido a exec 1>>"$LOG_FILE")

}


# error_exit: Imprime un mensaje de error y sale del script.

error_exit() {

    log "❌ ERROR FATAL: $1"

    log "⛔ La instalación ha terminado con un error. Revisa el log en '$LOG_FILE' para más detalles."

    exit 1

}


# warn: Imprime un mensaje de advertencia.

warn() {

    log "⚠️ ADVERTENCIA: $1"

}


# check_command: Verifica si un comando está disponible en el PATH.

check_command() {

    command -v "$1" &>/dev/null

}


# confirm_action: Pide confirmación al usuario.

confirm_action() {

    local prompt_message="$1"

    if [[ "$UNATTENDED_MODE" == "true" ]]; then

        log "✅ Modo desatendido: '$prompt_message' -> SÍ (por defecto)."

        return 0 # En modo desatendido, siempre 'sí'

    fi

    read -rp "$prompt_message (s/n): " response

    [[ "$response" =~ ^[Ss]$ ]]

}


# ─────────────────────────────────────────────────────────────

# 🔍 Detección del Sistema Operativo y Gestor de Paquetes


detect_os() {

    log "🔎 Detectando sistema operativo y distribución..."

    OS_TYPE=$(uname -s)


    case "$OS_TYPE" in

        Linux)

            if check_command "lsb_release"; then

                DISTRO_NAME=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

            elif [[ -f "/etc/os-release" ]]; then

                DISTRO_NAME=$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')

            else

                error_exit "No se pudo detectar la distribución de Linux. Instala 'lsb_release' (ej. 'sudo apt install lsb-release') o verifica /etc/os-release."

            fi

            log "✅ Sistema operativo detectado: Linux ($DISTRO_NAME)"


            case "$DISTRO_NAME" in

                ubuntu|debian|pop!_os|linuxmint)

                    PACKAGE_MANAGER="apt"

                    log "✅ Gestor de paquetes: apt"

                    ;;

                arch|manjaro|artix|garuda)

                    PACKAGE_MANAGER="pacman"

                    log "✅ Gestor de paquetes: pacman"

                    ;;

                fedora|centos|rhel)

                    PACKAGE_MANAGER="dnf"

                    log "✅ Gestor de paquetes: dnf"

                    ;;

                opensuse-leap|opensuse-tumbleweed)

                    PACKAGE_MANAGER="zypper"

                    log "✅ Gestor de paquetes: zypper"

                    ;;

                *)

                    error_exit "Distribución de Linux no soportada: $DISTRO_NAME. Por favor, añade soporte manualmente en la función 'detect_os'."

                    ;;

            esac

            ;;

        Darwin)

            PACKAGE_MANAGER="brew"

            log "✅ Sistema operativo detectado: macOS"

            log "✅ Gestor de paquetes: Homebrew"

            if ! check_command "brew"; then

                log "⚠️ Homebrew no está instalado. Iniciando instalación de Homebrew..."

                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error_exit "Fallo al instalar Homebrew."

                # Añadir Homebrew al PATH para la sesión actual si no está

                if [[ -f "/opt/homebrew/bin/brew" ]]; then # Para Apple Silicon

                    eval "$(/opt/homebrew/bin/brew shellenv)"

                elif [[ -f "/usr/local/bin/brew" ]]; then # Para Intel Macs

                    eval "$(/usr/local/bin/brew shellenv)"

                fi

                log "✅ Homebrew instalado."

            fi

            ;;

        *)

            error_exit "Sistema operativo no soportado: $OS_TYPE. Este script solo soporta Linux y macOS."

            ;;

    esac

}


# check_disk_space: Verifica el espacio libre en disco.

check_disk_space() {

    local required_gb=10 # Espacio mínimo requerido en GB

    local free_gb


    log "🔎 Verificando espacio libre en disco (mínimo ${required_gb}GB recomendado)..."


    if [[ "$OS_TYPE" == "Linux" ]]; then

        free_gb=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//' || echo "")

        if [[ -z "$free_gb" ]]; then

            warn "No se pudo determinar el espacio libre en disco. Continuando con precaución."

            return 0

        fi

        if [[ "$free_gb" -lt "$required_gb" ]]; then

            log "⚠️ ATENCIÓN: Solo quedan ${free_gb}GB de espacio libre en disco en el sistema. Se recomiendan ${required_gb}GB para una instalación completa."

            if ! confirm_action "¿Deseas continuar la instalación de todos modos?"; then

                error_exit "Espacio en disco insuficiente. Saliendo."

            fi

        else

            log "✅ Espacio libre en disco (${free_gb}GB) es suficiente."

        fi

    elif [[ "$OS_TYPE" == "Darwin" ]]; then

        free_gb=$(df -g / | awk 'NR==2 {print $4}' || echo "")

        if [[ -z "$free_gb" ]]; then

            warn "No se pudo determinar el espacio libre en disco en macOS. Continuará con precaución."

            return 0

        fi

        if [[ "$free_gb" -lt "$required_gb" ]]; then

            log "⚠️ ATENCIÓN: Solo quedan ${free_gb}GB de espacio libre en disco en el sistema. Se recomiendan ${required_gb}GB para una instalación completa."

            if ! confirm_action "Deseas continuar la instalación de todos modos?"; then

                error_exit "Espacio en disco insuficiente. Saliendo."

            fi

        else

            log "✅ Espacio libre en disco (${free_gb}GB) es suficiente."

        fi

    fi

}


# 📦 Instalación de Paquetes del Sistema

install_system_packages() {

    if [[ ${#REQUIRED_PACKAGES[@]} -eq 0 ]]; then

        log "ℹ️ No hay paquetes del sistema especificados para instalar en la selección actual."

        return

    fi


    log "📦 Actualizando listas de paquetes e instalando paquetes del sistema usando $PACKAGE_MANAGER..."

    case "$PACKAGE_MANAGER" in

        apt)

            sudo apt update || error_exit "Fallo al actualizar apt."

            sudo apt install -y "${REQUIRED_PACKAGES[@]}" || error_exit "Fallo al instalar paquetes con apt."

            ;;

        pacman)

            sudo pacman -Syu --noconfirm || error_exit "Fallo al actualizar pacman."

            # Si se ha elegido instalar desde AUR, usamos el helper

            if [[ "${INSTALL_CHOICES[aur_packages]}" == "y" && ( -n "$(command -v yay)" || -n "$(command -v paru)" ) ]]; then

                local aur_helper=""

                if command -v yay &>/dev/null; then aur_helper="yay"; else aur_helper="paru"; fi

                log "ℹ️ Usando $aur_helper para instalar paquetes, incluyendo los de AUR si se seleccionaron."

                "$aur_helper" -S --noconfirm "${REQUIRED_PACKAGES[@]}" || error_exit "Fallo al instalar paquetes con $aur_helper."

            else

                sudo pacman -S --noconfirm "${REQUIRED_PACKAGES[@]}" || error_exit "Fallo al instalar paquetes con pacman."

            fi

            ;;

        dnf)

            sudo dnf check-update || warn "Fallo al verificar actualizaciones de dnf."

            sudo dnf install -y "${REQUIRED_PACKAGES[@]}" || error_exit "Fallo al instalar paquetes con dnf."

            ;;

        zypper)

            sudo zypper refresh || error_exit "Fallo al actualizar zypper."

            sudo zypper install -y "${REQUIRED_PACKAGES[@]}" || error_exit "Fallo al instalar paquetes con zypper."

            ;;

        brew)

            brew update || error_exit "Fallo al actualizar Homebrew."

            brew install "${REQUIRED_PACKAGES[@]}" || error_exit "Fallo al instalar paquetes con brew."

            ;;

        *)

            error_exit "Gestor de paquetes desconocido: $PACKAGE_MANAGER"

            ;;

    esac

    log "✅ Paquetes del sistema instalados correctamente."

}


# ⚙️ Instalación de Herramientas Específicas (no de gestor de paquetes o que requieren pasos extra)


# install_rust: Instala Rust y Cargo usando rustup.

install_rust() {

    log "Iniciando instalación de Rust..."

    if ! check_command "cargo"; then

        log "🦀 Instalando Rust y Cargo con rustup. Esto puede tardar unos minutos..."

        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || error_exit "Fallo al instalar Rust."

        # Asegura que cargo esté en el PATH para la sesión actual

        # shellcheck disable=SC1090

        source "$HOME/.cargo/env" 2>/dev/null || warn "No se pudo cargar el entorno de Rust. Puede que necesites reiniciar tu shell o ejecutar 'source $HOME/.cargo/env'."

        log "✅ Rust y Cargo instalados."

    else

        log "🦀 Rust y Cargo ya están instalados. Verificando actualizaciones..."

        # shellcheck disable=SC1090

        source "$HOME/.cargo/env" 2>/dev/null || true # Cargar por si acaso

        rustup update || warn "Fallo al actualizar Rust. Puedes intentarlo manualmente con 'rustup update'."

        log "✅ Rust actualizado (si no estaba ya)."

    fi

    # SUGERENCIA: Aquí se podría añadir una comprobación de versión de Rust más estricta si fuera necesaria una versión específica.

    # local CURRENT_RUST_VERSION=$(cargo --version | awk '{print $2}')

    # local MIN_RUST_VERSION="1.70.0"

    # if [[ "$(printf '%s\n' "$MIN_RUST_VERSION" "$CURRENT_RUST_VERSION" | sort -V | head -n 1)" != "$MIN_RUST_VERSION" ]]; then

    #     warn "La versión de Rust ($CURRENT_RUST_VERSION) es menor que la mínima requerida ($MIN_RUST_VERSION)."

    # fi

}


# install_nvm: Instala Node Version Manager (nvm) y Node.js.

install_nvm() {

    log "Iniciando instalación de NVM..."

    if ! check_command "nvm"; then

        log "🌐 Instalando Node Version Manager (nvm)..."

        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash || error_exit "Fallo al instalar nvm."

        # Carga nvm en la sesión actual

        export NVM_DIR="$HOME/.nvm"

        # shellcheck disable=SC1090

        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

        # shellcheck disable=SC1090

        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

        log "✅ nvm instalado."


        log "🌐 Instalando la última versión LTS de Node.js con nvm..."

        nvm install --lts || warn "Fallo al instalar Node.js con nvm. Intenta 'nvm install --lts' manualmente más tarde."

        nvm use --lts || warn "Fallo al usar la última versión LTS de Node.js. Intenta 'nvm use --lts' manualmente más tarde."

        log "✅ Node.js LTS instalado (si no hubo errores)."

    else

        log "🌐 nvm ya está instalado."

        log "🌐 Actualizando la última versión LTS de Node.js con nvm..."

        # shellcheck disable=SC1090

        export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        nvm install --lts --reinstall-packages-from=current || warn "Fallo al actualizar Node.js con nvm. Intenta 'nvm install --lts --reinstall-packages-from=current' manualmente."

        nvm use --lts || warn "Fallo al usar la última versión LTS de Node.js. Intenta 'nvm use --lts' manualmente."

        log "✅ Node.js LTS actualizado (si no hubo errores)."

    fi

}


# install_go: Instala Go.

install_go() {

    log "Iniciando instalación de Go..."

    if ! check_command "go"; then

        log "🐹 Instalando Go. Esto descargará la última versión estable."

        local GO_VERSION

        GO_VERSION=$(curl -sL https://go.dev/VERSION?m=text | head -n 1 || error_exit "No se pudo obtener la última versión de Go.")

        local GO_TAR="go${GO_VERSION#go}.linux-amd64.tar.gz"

        local GO_URL="https://go.dev/dl/${GO_TAR}"


        log "  Descargando Go ($GO_VERSION) desde $GO_URL..."

        wget -q --show-progress "$GO_URL" -O "/tmp/${GO_TAR}" || error_exit "Fallo al descargar Go."

        sudo rm -rf /usr/local/go

        log "  Extrayendo Go a /usr/local/..."

        sudo tar -C /usr/local -xzf "/tmp/${GO_TAR}" || error_exit "Fallo al extraer Go."

        rm "/tmp/${GO_TAR}"


        # Añadir Go al PATH (se asume que ya lo tienes en tus dotfiles, pero para la sesión actual)

        export PATH=$PATH:/usr/local/go/bin

        log "✅ Go instalado."

    else

        log "🐹 Go ya está instalado."

        # SUGERENCIA: Aquí se podría implementar una actualización de Go o una verificación de versión.

    fi

}


# install_oh_my_zsh: Instala Oh My Zsh.

install_oh_my_zsh() {

    log "Iniciando instalación de Oh My Zsh..."

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then

        log "🐚 Instalando Oh My Zsh. Esto puede tardar un momento."

        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || warn "Fallo al instalar Oh My Zsh. Puedes intentarlo manualmente o configurarlo después."

        log "✅ Oh My Zsh instalado."

    else

        log "🐚 Oh My Zsh ya está instalado."

    fi

}


# install_starship: Instala Starship (prompt de shell).

install_starship() {

    log "Iniciando instalación de Starship..."

    if ! check_command "starship"; then

        log "🚀 Instalando Starship (prompt de shell).."

        curl -sS https://starship.rs/install.sh | sh -s -- -y || warn "Fallo al instalar Starship. Puedes intentarlo manualmente con 'curl -sS https://starship.rs/install.sh | sh'."

        log "✅ Starship instalado."

    else

        log "🚀 Starship ya está instalado."

    fi

}


# install_fzf: Instala fzf (buscador de archivos difuso).

install_fzf() {

    log "Iniciando instalación de fzf..."

    if ! check_command "fzf"; then

        log "🔍 Instalando fzf (fuzzy finder)..."

        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" || error_exit "Fallo al clonar fzf."

        log "  Ejecutando script de instalación de fzf..."

        yes | "$HOME/.fzf/install" || warn "Fallo al instalar fzf. Puedes ejecutar '$HOME/.fzf/install' manualmente."

        log "✅ fzf instalado."

    else

        log "🔍 fzf ya está instalado."

    fi

}


# install_neovim_plugins: Instala un gestor de plugins de Neovim (ej. Packer) y plugins.

install_neovim_plugins() {

    log "Iniciando instalación de plugins de Neovim..."

    if check_command "nvim"; then

        log "✨ Instalando gestor de plugins de Neovim (Packer)..."

        # Asume que estás usando Packer. Ajusta si usas otro gestor.

        if [[ ! -d "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim" ]]; then

            git clone --depth 1 https://github.com/wbthomason/packer.nvim \

                "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim" || warn "Fallo al clonar Packer."

        else

            log "✨ Packer ya está instalado."

        fi


        log "✨ Ejecutando instalación de plugins de Neovim (esto puede tardar y requerir interacción manual si hay errores)..."

        # Esto intentará ejecutar Neovim para instalar plugins.

        # Puede que necesites configurarlo en tus dotfiles de Neovim para que se ejecute automáticamente.

        nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' || warn "Fallo al sincronizar plugins de Neovim. Revisa tu configuración de Neovim y ejecuta ':PackerSync' dentro de Neovim."

        log "✅ Plugins de Neovim (intentado) instalados."

    else

        warn "Neovim no está instalado. Omite la instalación de plugins de Neovim."

    fi

}


# install_xdg_portal_hyprland: Compila e instala xdg-desktop-portal-hyprland

install_xdg_portal_hyprland() {

    log "Iniciando instalación de xdg-desktop-portal-hyprland..."

    if ! check_command "xdg-desktop-portal-hyprland"; then

        log "🖥️ Compilando e instalando xdg-desktop-portal-hyprland (necesario para compartición de pantalla en Wayland)..."

        local BUILD_DIR="$HOME/build/xdg-desktop-portal-hyprland"

        mkdir -p "$BUILD_DIR" || error_exit "Fallo al crear directorio de compilación para xdg-desktop-portal-hyprland."

        git clone https://github.com/hyprwm/xdg-desktop-portal-hyprland.git "$BUILD_DIR" || warn "Fallo al clonar xdg-desktop-portal-hyprland. Puede que ya exista o haya un problema de red."

        

        if [[ -d "$BUILD_DIR" ]]; then

            cd "$BUILD_DIR" || error_exit "No se pudo entrar al directorio de xdg-desktop-portal-hyprland."

            log "  Configurando Meson para xdg-desktop-portal-hyprland..."

            meson build --prefix=/usr || warn "Fallo en la configuración de Meson. Asegúrate de tener las dependencias de build."

            log "  Compilando xdg-desktop-portal-hyprland..."

            ninja -C build || warn "Fallo en la compilación. Revisa las dependencias y el log."

            log "  Instalando xdg-desktop-portal-hyprland..."

            sudo ninja -C build install || warn "Fallo en la instalación. Puede que necesites permisos o dependencias faltantes."

            cd - >/dev/null # Volver al directorio anterior

            log "✅ xdg-desktop-portal-hyprland instalado (si no hubo errores durante la compilación/instalación)."

        else

            warn "No se pudo clonar el repositorio de xdg-desktop-portal-hyprland. Omitiendo la compilación."

        fi

    else

        log "🖥️ xdg-desktop-portal-hyprland ya está instalado."

    fi

}


# install_eww_from_source: Compila e instala Eww desde la fuente.

install_eww_from_source() {

    log "Iniciando instalación de Eww..."

    if ! check_command "eww"; then

        log "🎨 Compilando e instalando Eww desde la fuente (requiere Rust y GTK/Cairo)..."

        local BUILD_DIR="$HOME/build/eww"

        mkdir -p "$BUILD_DIR" || error_exit "Fallo al crear directorio de compilación para Eww."

        git clone https://github.com/elkowar/eww.git "$BUILD_DIR" || warn "Fallo al clonar Eww. Puede que ya exista o haya un problema de red."


        if [[ -d "$BUILD_DIR" ]]; then

            cd "$BUILD_DIR" || error_exit "No se pudo entrar al directorio de Eww."

            # Asegúrate de que Rust esté en PATH para la sesión actual si aún no lo está

            # shellcheck disable=SC1090

            source "$HOME/.cargo/env" 2>/dev/null || true # Intenta cargar si existe, ignora error si no

            log "  Compilando Eww (modo release, features=wayland)..."

            cargo build --release --no-default-features --features=wayland || warn "Fallo en la compilación de Eww. Asegúrate de tener Rust y las dependencias GTK/Cairo/Pango."

            if [[ -f "target/release/eww" ]]; then

                sudo cp target/release/eww /usr/local/bin/ || warn "Fallo al copiar Eww al PATH. Puede que necesites permisos."

                log "✅ Eww instalado desde la fuente."

            else

                warn "Binario de Eww no encontrado después de la compilación. La instalación de Eww puede haber fallado."

            fi

            cd - >/dev/null

        else

            warn "No se pudo clonar el repositorio de Eww. Omitiendo la compilación."

        fi

    else

        log "🎨 Eww ya está instalado."

        # SUGERENCIA: Aquí se podría verificar la versión de Eww.

        # local CURRENT_EWW_VERSION=$("$(command -v eww)" --version 2>/dev/null | head -n 1)

        # log "Eww version: $CURRENT_EWW_VERSION"

    fi

}


# install_tiramisu_pipe: Copia TiramisuPipe desde la fuente.

install_tiramisu_pipe() {

    log "Iniciando instalación de TiramisuPipe..."

    if ! check_command "tiramisu"; then # Asumiendo que el binario se llama 'tiramisu'

        log "💬 Instalando TiramisuPipe desde la fuente (script Python)..."

        local BUILD_DIR="$HOME/build/tiramisu-pipe"

        mkdir -p "$BUILD_DIR" || error_exit "Fallo al crear directorio de compilación para TiramisuPipe."

        git clone https://github.com/donatello77/tiramisu-pipe.git "$BUILD_DIR" || warn "Fallo al clonar TiramisuPipe. Puede que ya exista o haya un problema de red."

        

        if [[ -d "$BUILD_DIR" ]]; then

            cd "$BUILD_DIR" || error_exit "No se pudo entrar al directorio de TiramisuPipe."

            log "  Copiando TiramisuPipe a /usr/local/bin/..."

            sudo cp tiramisu /usr/local/bin/tiramisu || warn "Fallo al copiar TiramisuPipe al PATH. Puede que necesites permisos."

            sudo chmod +x /usr/local/bin/tiramisu || warn "Fallo al dar permisos de ejecución a TiramisuPipe."

            cd - >/dev/null

            log "✅ TiramisuPipe instalado."

        else

            warn "No se pudo clonar el repositorio de TiramisuPipe. Omitiendo la instalación."

        fi

    else

        log "💬 TiramisuPipe ya está instalado."

    fi

}


# install_aur_helper: Instala Paru (o Yay si ya existe) para Arch Linux.

install_aur_helper() {

    if [[ "$PACKAGE_MANAGER" != "pacman" ]]; then

        return # Solo para Arch-based

    fi


    if check_command "yay" || check_command "paru"; then

        log "ℹ️ Un AUR helper (yay/paru) ya está instalado. No se necesita instalación adicional."

        return

    fi


    log "🌐 No se encontró un AUR helper (yay/paru)."

    if confirm_action "¿Deseas instalar 'paru' (un AUR helper) desde la fuente? (Esto es necesario para instalar paquetes de AUR)"; then

        log "🛠️ Instalando paru desde la fuente..."

        local BUILD_DIR="$HOME/build/paru"

        mkdir -p "$BUILD_DIR" || error_exit "Fallo al crear directorio de compilación para paru."

        git clone https://aur.archlinux.org/paru.git "$BUILD_DIR" || error_exit "Fallo al clonar el repositorio de paru."

        

        cd "$BUILD_DIR" || error_exit "No se pudo entrar al directorio de paru."

        # Dependencias de paru (base-devel) ya deberían estar instaladas si se eligieron Dev Tools

        makepkg -si --noconfirm || error_exit "Fallo al compilar e instalar paru. Asegúrate de tener 'base-devel' instalado."

        cd - >/dev/null

        log "✅ paru instalado."

    else

        warn "No se instalará un AUR helper. Los paquetes de AUR no se podrán gestionar automáticamente."

        INSTALL_CHOICES[aur_packages]="n" # Deshabilita la opción de AUR si el usuario no quiere el helper

    fi

}



# ⚙️ Ejecución de Comandos Personalizados

run_custom_commands() {

    if [[ ${#CUSTOM_COMMANDS[@]} -eq 0 ]]; then

        log "ℹ️ No hay comandos personalizados especificados para ejecutar en la selección actual."

        return

    fi


    log "🚀 Ejecutando comandos personalizados..."

    for cmd_func in "${CUSTOM_COMMANDS[@]}"; do

        log "  Ejecutando función: '$cmd_func'"

        # Ejecuta la función por su nombre

        "$cmd_func" || warn "La función '$cmd_func' reportó un fallo. Revisa el log para detalles."

    done

    log "✅ Comandos personalizados ejecutados."

}


# ─────────────────────────────────────────────────────────────

# 📋 Configuración de Dependencias


# configure_dependencies: Define qué paquetes y herramientas se deben instalar.

# PERSONALIZA ESTA FUNCIÓN SEGÚN TUS NECESIDADES.

configure_dependencies() {

    # Limpia las listas anteriores antes de rellenar

    REQUIRED_PACKAGES=()

    CUSTOM_COMMANDS=()


    log "⚙️ Configurando listas de paquetes y comandos personalizados según las selecciones del usuario..."


    # Common basic tools for all installs

    REQUIRED_PACKAGES+=(git curl wget)


    # ----------------------------------------------------------------------------------------------------------------

    # Definición de paquetes por categoría

    # ----------------------------------------------------------------------------------------------------------------


    # 1. Core Hyprland & Wayland

    if [[ "${INSTALL_CHOICES[core_hyprland]}" == "y" ]]; then

        log "  Añadiendo dependencias para 'Core Hyprland & Wayland'..."

        case "$DISTRO_NAME" in

            ubuntu|debian|pop!_os|linuxmint)

                REQUIRED_PACKAGES+=(

                    hyprland # Si tienes un PPA añadido, si no, considera compilarlo.

                    libwayland-dev libinput-dev libxkbcommon-dev libgl-dev libegl-dev libdrm-dev libgbm-dev

                    libpixman-1-dev libudev-dev libdisplay-info-dev libseat-dev libxcb-dri3-dev libvulkan-dev

                    libxcb-randr0-dev libxcb-util-dev libxcb-icccm4-dev libxcb-ewmh-dev libxcb-xinput-dev

                    libtomlplusplus-dev # Para Hyprland y algunos componentes Wayland

                    hyprpicker wl-clipboard wf-recorder # Hyprland Ecosystem Utilities

                    polkitd polkit-gnome-agent-1 network-manager-gnome brightnessctl playerctl xdg-utils

                    swayidle swaylock wlogout nwg-look # Lockscreen, power, theming, idle

                    pipewire pipewire-audio-client-libraries pipewire-pulse pipewire-alsa wireplumber

                    libspa-0.2-bluetooth pipewire-jack pulseaudio-utils # pulseaudio-utils para 'pactl'

                    mesa-utils libgl1-mesa-dri vulkan-tools

                    lsb-release # Asegurar que lsb-release esté disponible para detección de distro

                )

                ;;

            arch|manjaro|artix|garuda)

                REQUIRED_PACKAGES+=(

                    hyprland # Desde los repos oficiales o AUR (hyprland-git)

                    wayland wayland-protocols libinput libxkbcommon mesa egl-wayland libdrm libgbm

                    pixman systemd-libs libdisplay-info libseat xcb-util-keysyms vulkan-headers vulkan-icd-loader

                    libxcb libxcb-util libxcb-icccm libxcb-ewmh libxcb-xinput

                    tomlplusplus

                    hyprpicker wl-clipboard wf-recorder

                    polkit polkit-gnome networkmanager brightnessctl playerctl xdg-utils

                    swayidle swaylock wlogout nwg-look

                    pipewire pipewire-pulse pipewire-alsa wireplumber pipewire-jack pipewire-v4l2 pipewire-zeroconf

                    mesa vulkan-radeon vulkan-intel # Ajusta según tu GPU

                )

                ;;

            fedora)

                REQUIRED_PACKAGES+=(

                    hyprland # Puede requerir COPR (ej. copr:copr.fedorainfracloud.org:solopasha:hyprland)

                    wayland-devel libinput-devel libxkbcommon-devel mesa-libGL-devel mesa-libEGL-devel libdrm-devel libgbm-devel

                    pixman-devel systemd-devel libdisplay-info-devel libseat-devel xcb-util-keysyms-devel vulkan-headers vulkan-loader

                    libxcb-devel libxcb-util-devel libxcb-icccm-devel libxcb-ewmh-devel libxcb-xinput-devel

                    tomlplusplus-devel

                    hyprpicker wl-clipboard wf-recorder

                    polkit polkit-gnome network-manager-applet brightnessctl playerctl xdg-utils

                    swayidle swaylock wlogout nwg-look

                    pipewire pipewire-pulseaudio pipewire-alsa wireplumber pipewire-jack-audio-connection-kit

                    mesa-vulkan-drivers # Ajusta según tu GPU

                )

                ;;

            opensuse-leap|opensuse-tumbleweed)

                REQUIRED_PACKAGES+=(

                    hyprland # Puede requerir repos de comunidad o manual build

                    wayland-devel libinput-devel libxkbcommon-devel Mesa-devel libdrm-devel libgbm-devel

                    pixman-devel systemd-devel libdisplay-info-devel libseat-devel xcb-util-keysyms-devel vulkan-headers vulkan-loader

                    libxcb-devel libxcb-util-devel libxcb-icccm-devel libxcb-ewmh-devel libxcb-xinput-devel

                    tomlplusplus-devel

                    hyprpicker wl-clipboard wf-recorder

                    polkit polkit-gnome NetworkManager-applet brightnessctl playerctl xdg-utils

                    swayidle swaylock wlogout nwg-look

                    pipewire pipewire-pulseaudio pipewire-alsa wireplumber pipewire-jack-audio-connection-kit

                    Mesa-vulkan-drivers # Ajusta según tu GPU

                )

                ;;

            *)

                warn "No hay una lista de paquetes 'Core Hyprland' definida para $DISTRO_NAME. Algunos componentes pueden no instalarse."

                ;;

        esac

        CUSTOM_COMMANDS+=( "install_xdg_portal_hyprland" )

    fi


    # 2. Eww & TiramisuPipe

    if [[ "${INSTALL_CHOICES[eww_tiramisupipe]}" == "y" ]]; then

        log "  Añadiendo dependencias para 'Eww & TiramisuPipe'..."

        case "$DISTRO_NAME" in

            ubuntu|debian|pop!_os|linuxmint)

                REQUIRED_PACKAGES+=(

                    python3 python3-pip # Para TiramisuPipe y otras utilidades python

                    # Dependencias de desarrollo para Eww (si se compila desde la fuente)

                    libgtk-3-dev libglib2.0-dev libgdk-pixbuf2.0-dev libcairo2-dev libpangocairo-1.0-0-dev

                    libjson-glib-dev libdbus-1-dev libxml2-dev libyaml-cpp-dev libgirepository1.0-dev libsass-dev

                    # Dependencias para widgets de Eww (información del sistema)

                    acpi lm-sensors upower jq # Para batería, temperatura, CPU, JSON parsing

                )

                ;;

            arch|manjaro|artix|garuda)

                REQUIRED_PACKAGES+=(

                    python python-pip

                    # Dependencias de desarrollo para Eww (si se compila desde la fuente)

                    gtk3 glib2 gdk-pixbuf2 cairo pango json-glib dbus libxml2 yaml-cpp gobject-introspection libsass

                    acpi lm_sensors upower jq

                )

                ;;

            fedora)

                REQUIRED_PACKAGES+=(

                    python3 python3-pip

                    # Dependencias de desarrollo para Eww (si se compila desde la fuente)

                    gtk3-devel glib2-devel gdk-pixbuf2-devel cairo-devel pango-devel json-glib-devel dbus-devel libxml2-devel yaml-cpp-devel gobject-introspection-devel libs 