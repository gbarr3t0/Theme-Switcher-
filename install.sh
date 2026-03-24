#!/usr/bin/env bash

# =============================================================================
# INSTALLER
# Bootstrap de dependências + instalação do binário
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# METADATA
# -----------------------------------------------------------------------------
readonly APP_NAME="themes-core"
readonly BIN_NAME="themes-core"
readonly INSTALL_DIR="${HOME}/.local/bin"
readonly TARGET_PATH="${INSTALL_DIR}/${BIN_NAME}"

# -----------------------------------------------------------------------------
# LOGGING
# -----------------------------------------------------------------------------
log()   { printf "[INFO] %s\n" "$*"; }
ok()    { printf "[OK] %s\n" "$*"; }
fail()  { printf "[ERROR] %s\n" "$*" >&2; exit 1; }

# -----------------------------------------------------------------------------
# HELPERS
# -----------------------------------------------------------------------------
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

require_sudo() {
    if ! command_exists sudo; then
        fail "sudo não encontrado. Instale manualmente as dependências."
    fi
}

detect_pm() {
    if command_exists pacman; then
        echo "pacman"
    elif command_exists apt; then
        echo "apt"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists zypper; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# -----------------------------------------------------------------------------
# INSTALLERS
# -----------------------------------------------------------------------------
install_arch() {
    log "Instalando dependências (pacman)"
    sudo pacman -Sy --noconfirm \
        python-pywal jq file \
        feh nitrogen \
        rofi wofi \
        cava
}

install_debian() {
    log "Instalando dependências (apt)"
    sudo apt update
    sudo apt install -y \
        python3 python3-pip jq file \
        feh nitrogen \
        rofi \
        cava

    if ! command_exists wal; then
        log "Instalando pywal via pip"
        pip3 install --user pywal
    fi
}

install_fedora() {
    log "Instalando dependências (dnf)"
    sudo dnf install -y \
        python3 python3-pip jq file \
        feh nitrogen \
        rofi \
        cava

    if ! command_exists wal; then
        pip3 install --user pywal
    fi
}

install_suse() {
    log "Instalando dependências (zypper)"
    sudo zypper install -y \
        python3 python3-pip jq file \
        feh nitrogen \
        rofi \
        cava

    if ! command_exists wal; then
        pip3 install --user pywal
    fi
}

install_wayland_tools() {
    if command_exists swww; then
        return 0
    fi

    log "Tentando instalar swww (Wayland)"

    case "$1" in
        pacman) sudo pacman -S --noconfirm swww ;;
        apt)    sudo apt install -y swww || true ;;
        dnf)    sudo dnf install -y swww || true ;;
        zypper) sudo zypper install -y swww || true ;;
    esac
}

# -----------------------------------------------------------------------------
# SCRIPT INSTALL
# -----------------------------------------------------------------------------
install_binary() {
    local source="./themes-core-v4.sh"

    [[ -f "$source" ]] || fail "Arquivo não encontrado: $source"

    mkdir -p "$INSTALL_DIR"
    cp "$source" "$TARGET_PATH"
    chmod +x "$TARGET_PATH"

    ok "Instalado em ${TARGET_PATH}"
}

# -----------------------------------------------------------------------------
# PATH VALIDATION
# -----------------------------------------------------------------------------
ensure_path() {
    case ":$PATH:" in
        *":$INSTALL_DIR:"*) return 0 ;;
        *)
            printf "\n[WARN] %s não está no PATH\n" "$INSTALL_DIR"
            printf "Adicione ao seu shell:\n\n"
            printf "  export PATH=\"%s:\$PATH\"\n\n" "$INSTALL_DIR"
            ;;
    esac
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
main() {
    log "Detectando ambiente..."

    local pm
    pm=$(detect_pm)

    [[ "$pm" != "unknown" ]] || fail "Gerenciador de pacotes não suportado"

    require_sudo

    case "$pm" in
        pacman) install_arch ;;
        apt)    install_debian ;;
        dnf)    install_fedora ;;
        zypper) install_suse ;;
    esac

    install_wayland_tools "$pm"

    log "Instalando binário..."
    install_binary

    ensure_path

    ok "Instalação concluída"
    printf "\nUse: %s --menu\n" "$BIN_NAME"
}

main "$@"
