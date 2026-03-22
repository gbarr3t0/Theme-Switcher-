#!/usr/bin/env bash

# =============================================================================
# TITLE:        themes-core Alpha (Universal Edition)
# DESCRIPTION:  Agnostic Theme Sync Engine (Wayland/X11 & Multi-WM)
# FEATURES:     Runtime Detection, CAVA Gradient Fix, TTY Persistence
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# --- RUNTIME ENVIRONMENT DETECTION ---
readonly SESSION_TYPE="${XDG_SESSION_TYPE:-unknown}"
readonly CURRENT_WM="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-unknown}}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# --- GLOBAL SETTINGS & PATHS ---
readonly XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly XDG_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}"
readonly LOCAL_THEME_DIR="${XDG_CONFIG}/themes"
readonly CORE_POINTER="${LOCAL_THEME_DIR}/core_path.ptr"
readonly PYWAL_CACHE="${XDG_CACHE}/wal"

CORE_PATH=""
WALL_DIR=""
THEME_CACHE=""

# --- INITIALIZATION ---
setup_core_environment() {
    mkdir -p "$LOCAL_THEME_DIR"
    if [[ ! -f "$CORE_POINTER" ]]; then
        local default_root="${HOME}/theme_CORE"
        mkdir -p "$default_root"/{wallpapers,cache,logs,temp}
        echo "$default_root" > "$CORE_POINTER"
    fi
    CORE_PATH=$(cat "$CORE_POINTER")
    WALL_DIR="${CORE_PATH}/wallpapers"
    THEME_CACHE="${CORE_PATH}/cache"
    mkdir -p "$WALL_DIR" "$THEME_CACHE"
}

# --- MODULE: WALLPAPER ENGINE (X11/WAYLAND AGNOSTIC) ---
dispatch_wallpaper() {
    local img="$1"
    
    if [[ "$SESSION_TYPE" == "wayland" ]]; then
        if command -v swww &>/dev/null; then
            swww query || swww-daemon >/dev/null 2>&1 &
            swww img "$img" --transition-type wipe --transition-fps 60 --transition-duration 1.2 &
        elif command -v hyprpaper &>/dev/null; then
            hyprctl hyprpaper preload "$img" && hyprctl hyprpaper wallpaper ",$img" &
        fi
    else
        # X11 Fallback Logic
        if command -v feh &>/dev/null; then
            feh --bg-fill "$img" &
        elif command -v nitrogen &>/dev/null; then
            nitrogen --set-zoom-fill "$img" --save &
        fi
    fi
}

# --- MODULE: WM STYLING (HYPRLAND/SWAY/GENERIC) ---
sync_wm_styles() {
    local json="$1"
    local c1=$(jq -r '.colors.color1' "$json" | sed 's/#//')
    local c2=$(jq -r '.colors.color2' "$json" | sed 's/#//')

    case "$CURRENT_WM" in
        *Hyprland*)
            # Fix para garantir que hyprctl encontre a instância no Wayland
            if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
                export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t "$XDG_RUNTIME_DIR/hypr/" 2>/dev/null | head -n1 || true)
            fi
            hyprctl --batch "keyword general:col.active_border rgba(${c2}ff) rgba(${c1}aa) 45deg; keyword general:col.inactive_border rgba(${c1}aa); keyword decoration:col.shadow rgba(${c1}00);" >/dev/null 2>&1 || true
            ;;
        *Sway*)
            swaymsg "client.focused #$c2 #$c2 #ffffff #$c1" >/dev/null 2>&1 || true
            ;;
        *)
            # Para outros WMs, Pywal já trata via Xresources por padrão
            echo "[INFO] No specific styling for $CURRENT_WM. Using Xresources fallback."
            ;;
    esac
}

# --- MODULE: CAVA PATCHER (GRADIENT FIX) ---
patch_cava() {
    local json="$1"
    local config="${XDG_CONFIG}/cava/config"
    
    if [[ -f "$config" ]]; then
        local cl1=$(jq -r '.colors.color1' "$json")
        local cl2=$(jq -r '.colors.color2' "$json")

        # Atomic sed operations for config safety
        sed -i "s/^gradient =.*/gradient = 1/" "$config"
        sed -i "s/^gradient_count =.*/gradient_count = 2/" "$config"
        sed -i "s/^gradient_color_1 =.*/gradient_color_1 = '$cl1'/" "$config"
        sed -i "s/^gradient_color_2 =.*/gradient_color_2 = '$cl2'/" "$config"
        sed -i "/^gradient_color_[3-6]/d" "$config"

        pkill -USR1 cava || true
    fi
}

# --- MODULE: UI SELECTOR (WOFI/ROFI FALLBACK) ---
invoke_menu() {
    local style_file="${THEME_CACHE}/wofi.css"
    
    if command -v wofi &>/dev/null && [[ "$SESSION_TYPE" == "wayland" ]]; then
        local opts=()
        [[ -f "$style_file" ]] && opts=(--style "$style_file")
        ls "$WALL_DIR" | sort | wofi --dmenu --prompt "Theme Selector" --width 450 --height 350 "${opts[@]:-}" 2>/dev/null
    elif command -v rofi &>/dev/null; then
        ls "$WALL_DIR" | sort | rofi -dmenu -p "Theme Selector"
    else
        ls "$WALL_DIR" | head -n 1
    fi
}

# --- CORE LOGIC: THEME SYNCHRONIZATION ---
apply_theme_sync() {
    local wall_path="$1"
    local json_file="${PYWAL_CACHE}/colors.json"

    # Execution Pipeline
    dispatch_wallpaper "$wall_path"
    sync_wm_styles "$json_file"
    patch_cava "$json_file"

    # Dynamic UI Styling (Wofi)
    {
        echo "window { background-color: $(jq -r '.special.background' "$json_file"); color: $(jq -r '.special.foreground' "$json_file"); border: 2px solid $(jq -r '.colors.color2' "$json_file"); font-family: 'JetBrainsMono NF'; }"
        echo "#entry:selected { background-color: $(jq -r '.colors.color2' "$json_file"); }"
    } > "${THEME_CACHE}/wofi.css"

    # TTY Sequence Injection (Persistence Fix)
    if [[ -f "${PYWAL_CACHE}/sequences" ]]; then
        for tty in /dev/pts/[0-9]*; do
            [[ -w "$tty" ]] && cat "${PYWAL_CACHE}/sequences" > "$tty" 2>/dev/null &
        done
    fi
}

main() {
    setup_core_environment
    
    local target="${1:-}"
    [[ -z "$target" ]] && target=$(invoke_menu)
    [[ -z "$target" ]] && exit 0

    # Path resolution
    [[ -f "${WALL_DIR}/${target}" ]] && target="${WALL_DIR}/${target}"

    if [[ -f "$target" ]]; then
        # Backend processing
        wal -i "$target" -n -q --backend haishoku >/dev/null 2>&1 || wal -i "$target" -n -q --backend magick
        
        apply_theme_sync "$target"
        
        # Cross-distro notification
        notify-send -a "themes-core Alpha" -i "$target" "Theme Applied" "$(basename "$target")"
    else
        echo "[ERROR] Target file not found: $target"
        exit 1
    fi
}

main "$@"
