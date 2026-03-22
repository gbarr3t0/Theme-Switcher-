#!/usr/bin/env bash

# =============================================================================
# REPO:         themes-core-alpha
# MODULE:       Universal Dependency Resolver
# DESCRIPTION:  Multi-distro support (Arch, Debian/Ubuntu, Fedora, SUSE)
# =============================================================================

set -euo pipefail

# --- RUNTIME STACK ---
readonly DEPS=("python-pywal" "swww" "jq" "imagemagick" "wofi" "cava")

echo "[BOOTSTRAP] Initializing Universal Environment Check..."

# --- PACKAGE MANAGER DETECTOR ---
install_logic() {
    local pkgs=("$@")
    
    if command -v pacman &>/dev/null; then
        echo "[OS] Arch-based detected."
        sudo pacman -S --needed "${pkgs[@]}"
    elif command -v apt-get &>/dev/null; then
        echo "[OS] Debian/Ubuntu-based detected."
        sudo apt-get update && sudo apt-get install -y "${pkgs[@]}"
    elif command -v dnf &>/dev/null; then
        echo "[OS] Fedora-based detected."
        sudo dnf install -y "${pkgs[@]}"
    elif command -v zypper &>/dev/null; then
        echo "[OS] OpenSUSE-based detected."
        sudo zypper install -y "${pkgs[@]}"
    else
        echo "[ERROR] Unsupported Package Manager. Install manually: ${pkgs[*]}"
        exit 1
    fi
}

# --- VALIDATION ENGINE ---
resolve_dependencies() {
    local missing=()
    for item in "${DEPS[@]}"; do
        if ! command -v "$item" &>/dev/null; then
            # Pequeno fix: No Ubuntu/Debian alguns pacotes tem nomes diferentes
            if [[ "$item" == "python-pywal" ]] && command -v apt-get &>/dev/null; then
                missing+=("python3-pywal")
            else
                missing+=("$item")
            fi
        fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
        echo "[SUCCESS] Environment is already compliant."
    else
        echo "[ACTION] Missing components: ${missing[*]}"
        read -p "[PROMPT] Auto-install detected dependencies? [y/N]: " confirm
        [[ "$confirm" =~ ^[yY]$ ]] && install_logic "${missing[@]}"
    fi
}

main() {
    resolve_dependencies
    
    if [[ -f "themes-core-alpha.sh" ]]; then
        chmod +x themes-core-alpha.sh
        echo "[CHMOD] themes-core-alpha.sh is now executable."
    fi
    
    echo "[DONE] Setup finished."
}

main "$@"
