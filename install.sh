#!/usr/bin/env bash

# =============================================================================
# THEMES-CORE INSTALLER
# Cross-Distro Dependency Installer + Setup
# =============================================================================

set -euo pipefail

SCRIPT_NAME="themes-core-installer"

# --- UTILS ---

log() {
    echo "[INFO] $1"
}

success() {
    echo "[OK] $1"
}

error() {
    echo "[ERROR] $1"
    exit 1
}

command_exists() {
    command -v "$1" &>/dev/null
}

# --- DETECT PACKAGE MANAGER ---

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

# --- INSTALL FUNCTIONS ---

install_pacman() {
    sudo pacman -Sy --noconfirm \
        python-pywal jq file \
        feh nitrogen \
        rofi wofi \
        cava
}

install_apt() {
    sudo apt update
    sudo apt install -y \
        python3-pip jq file \
        feh nitrogen \
        rofi \
        cava

    pip3 install pywal
}

install_dnf() {
    sudo dnf install -y \
        python3-pip jq file \
        feh nitrogen \
        rofi \
        cava

    pip3 install pywal
}

install_zypper() {
    sudo zypper install -y \
        python3-pip jq file \
        feh nitrogen \
        rofi \
        cava

    pip3 install pywal
}

# --- OPTIONAL (WAYLAND) ---

install_wayland_tools() {
    if command_exists pacman; then
        sudo pacman -S --noconfirm swww
    elif command_exists apt; then
        sudo apt install -y swww || true
    elif command_exists dnf; then
        sudo dnf install -y swww || true
    fi
}

# --- COPY SCRIPT ---

install_script() {
    local target="$HOME/.local/bin/themes-core"

    mkdir -p "$HOME/.local/bin"
    cp themes-core-v4.sh "$target"
    chmod +x "$target"

    success "Script instalado em $target"
}

# --- MAIN ---

main() {
    log "Detectando gerenciador de pacotes..."

    PM=$(detect_pm)

    case "$PM" in
        pacman)
            log "Usando pacman (Arch-based)"
            install_pacman
            ;;
        apt)
            log "Usando apt (Debian/Ubuntu)"
            install_apt
            ;;
        dnf)
            log "Usando dnf (Fedora)"
            install_dnf
            ;;
        zypper)
            log "Usando zypper (openSUSE)"
            install_zypper
            ;;
        *)
            error "Gerenciador de pacotes não suportado"
            ;;
    esac

    log "Instalando ferramentas Wayland (se disponível)..."
    install_wayland_tools

    log "Instalando script..."
    install_script

    success "Instalação concluída com sucesso!"
    echo
    echo "Use: themes-core --menu"
}

main "$@"
