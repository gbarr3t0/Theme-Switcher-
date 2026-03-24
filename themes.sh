#!/usr/bin/env bash
# =============================================================================
# THEMES-CORE v4.0
# Theme sync engine for Linux desktops
# Focus: low-noise output, safe fallbacks, fast path execution
# =============================================================================

set -Eeuo pipefail
IFS=$'\n\t'
shopt -s nullglob

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename -- "${BASH_SOURCE[0]}")"
readonly VERSION="4.0.0"

readonly DEBUG="${DEBUG:-0}"
readonly VERBOSE="${VERBOSE:-0}"
readonly NOTIFY_ENABLED="${NOTIFY_ENABLED:-1}"
readonly NOTIFY_TIMEOUT="${NOTIFY_TIMEOUT:-1800}"
readonly TERM_REFRESH_DELAY="${TERM_REFRESH_DELAY:-0.08}"
readonly DEFAULT_MENU_PROMPT="${DEFAULT_MENU_PROMPT:-Selecione um tema}"
readonly THEME_ROOT_DEFAULT="${THEME_ROOT_DEFAULT:-$HOME/.local/share/themes-core}"
readonly THEME_POINTER="${XDG_CONFIG_HOME:-$HOME/.config}/themes/core_path.ptr"

readonly XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
readonly XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
readonly PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

readonly LOCAL_THEME_DIR="${XDG_CONFIG_HOME}/themes"
readonly PYWAL_CACHE="${XDG_CACHE_HOME}/wal"
readonly THEMES_LOG="${XDG_CACHE_HOME}/themes-core.log"
readonly TEMP_DIR="${TMPDIR:-/tmp}/themes-core-${$}"
readonly LOCK_FILE="${XDG_RUNTIME_DIR}/themes-core.lock"

CORE_PATH=""
WALL_DIR=""
THEME_CACHE=""
HISTORY_FILE=""
BACKUP_DIR=""
CURRENT_WM=""
SESSION_TYPE="${XDG_SESSION_TYPE:-unknown}"
NOTIFICATION_DAEMON="none"

readonly RUN_USER="${USER:-$(id -un 2>/dev/null || printf '%s' "$(id -u)")}"

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly GRAY='\033[0;90m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

readonly CHECKMARK='✓'
readonly CROSSMARK='✗'

trap '_cleanup' EXIT
trap '_handle_error "${LINENO}" "${BASH_COMMAND}" "$?"' ERR
trap '_handle_interrupt' INT TERM

# -----------------------------------------------------------------------------
#  logging
# -----------------------------------------------------------------------------

timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

log_file() {
    local level="$1" msg="$2"
    printf '[%s] [%s] %s\n' "$(timestamp)" "$level" "$msg" >> "$THEMES_LOG"
}

log_debug() {
    [[ "$DEBUG" == "1" ]] || return 0
    local msg="$1"
    printf '%b[DEBUG]%b %s\n' "${GRAY}" "${NC}" "$msg" >&2
    log_file "DEBUG" "$msg"
}

log_verbose() {
    [[ "$VERBOSE" == "1" ]] || return 0
    local msg="$1"
    printf '%b%s%b\n' "${CYAN}${DIM}" "$msg" "${NC}" >&2
    log_file "VERBOSE" "$msg"
}

log_error() {
    local msg="$1"
    printf '%b[ERROR]%b %s\n' "${RED}" "${NC}" "$msg" >&2
    log_file "ERROR" "$msg"
}

notify_result() {
    [[ "$NOTIFY_ENABLED" == "1" ]] || return 0

    local level="$1" msg="$2"
    local urgency="low"

    case "$level" in
        ok) urgency="low" ;;
        err) urgency="critical" ;;
        *) urgency="normal" ;;
    esac

    if command_exists notify-send; then
        notify-send -u "$urgency" -t "$NOTIFY_TIMEOUT" -a "themes-core" "themes-core" "$msg" 2>/dev/null || true
    elif command_exists dunstify; then
        dunstify -u "$urgency" -t "$NOTIFY_TIMEOUT" -a "themes-core" "themes-core" "$msg" 2>/dev/null || true
    fi
}

# -----------------------------------------------------------------------------
#  helpers
# -----------------------------------------------------------------------------

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

trim_hash() {
    printf '%s' "${1#\#}"
}

is_valid_image() {
    local file="$1"

    [[ -f "$file" ]] || return 1

    local mime_type=""
    if command_exists file; then
        mime_type="$(file --mime-type -b "$file" 2>/dev/null || true)"
        [[ "$mime_type" == image/* ]] && return 0
    fi

    case "${file##*.}" in
        jpg|jpeg|png|gif|bmp|webp|svg|avif|JPG|JPEG|PNG|GIF|BMP|WEBP|SVG|AVIF) return 0 ;;
        *) return 1 ;;
    esac
}

first_existing() {
    local candidate
    for candidate in "$@"; do
        [[ -n "$candidate" ]] && [[ -e "$candidate" ]] && { printf '%s\n' "$candidate"; return 0; }
    done
    return 1
}

safe_mkdir() {
    mkdir -p -- "$@"
}

resolve_theme_root() {
    if [[ -f "$THEME_POINTER" ]]; then
        local ptr
        ptr="$(<"$THEME_POINTER")"
        [[ -n "$ptr" ]] && printf '%s\n' "$ptr" && return 0
    fi
    printf '%s\n' "$THEME_ROOT_DEFAULT"
}

load_theme_paths() {
    CORE_PATH="$(resolve_theme_root)"
    WALL_DIR="${CORE_PATH}/wallpapers"
    THEME_CACHE="${CORE_PATH}/cache"
    HISTORY_FILE="${CORE_PATH}/history/applied_themes.json"
    BACKUP_DIR="${CORE_PATH}/backups"
}

init_core() {
    safe_mkdir "$LOCAL_THEME_DIR" "$TEMP_DIR" "$XDG_CACHE_HOME"
    : > "$THEMES_LOG"

    safe_mkdir "$THEME_ROOT_DEFAULT"/{wallpapers,cache,logs,temp,history,backups}

    if [[ ! -f "$THEME_POINTER" ]]; then
        printf '%s\n' "$THEME_ROOT_DEFAULT" > "$THEME_POINTER"
    fi

    load_theme_paths

    if [[ ! -d "$CORE_PATH" ]]; then
        safe_mkdir "$CORE_PATH" "$CORE_PATH/wallpapers" "$CORE_PATH/cache" "$CORE_PATH/logs" "$CORE_PATH/temp" "$CORE_PATH/history" "$CORE_PATH/backups"
    fi

    safe_mkdir "$WALL_DIR" "$THEME_CACHE" "$(dirname -- "$HISTORY_FILE")" "$BACKUP_DIR"

    if [[ ! -f "$HISTORY_FILE" ]]; then
        printf '{"last_applied":null,"history":[]}\n' > "$HISTORY_FILE"
    fi
}

validate_dependencies() {
    local required=("wal" "jq" "file")
    local missing=()

    local cmd
    for cmd in "${required[@]}"; do
        command_exists "$cmd" || missing+=("$cmd")
    done

    if ((${#missing[@]})); then
        local msg="TEMA NÃO-APLICADO: dependências faltando: ${missing[*]}"
        log_error "$msg"
        notify_result err "$msg"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
#  desktop detection
# -----------------------------------------------------------------------------

detect_session() {
    case "${XDG_SESSION_TYPE:-}" in
        wayland|x11) printf '%s\n' "${XDG_SESSION_TYPE}" ;;
        *) if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then printf 'wayland\n'; else printf 'x11\n'; fi ;;
    esac
}

detect_desktop_environment() {
    local env="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-}}"
    env="${env,,}"

    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] || pgrep -xu "$RUN_USER" hyprland >/dev/null 2>&1; then
        printf 'hyprland\n'; return 0
    fi
    if [[ -n "${SWAYSOCK:-}" ]] || pgrep -xu "$RUN_USER" sway >/dev/null 2>&1; then
        printf 'sway\n'; return 0
    fi
    if [[ "$env" == *gnome* ]] || pgrep -xu "$RUN_USER" gnome-shell >/dev/null 2>&1; then
        printf 'gnome\n'; return 0
    fi
    if [[ "$env" == *kde* || "$env" == *plasma* ]] || pgrep -xu "$RUN_USER" plasmashell >/dev/null 2>&1; then
        printf 'kde\n'; return 0
    fi
    if [[ "$env" == *xfce* ]] || pgrep -xu "$RUN_USER" xfce4-session >/dev/null 2>&1; then
        printf 'xfce\n'; return 0
    fi
    if [[ "$env" == *cinnamon* ]] || pgrep -xu "$RUN_USER" cinnamon-session >/dev/null 2>&1; then
        printf 'cinnamon\n'; return 0
    fi
    if [[ "$env" == *mate* ]] || pgrep -xu "$RUN_USER" mate-session >/dev/null 2>&1; then
        printf 'mate\n'; return 0
    fi
    if [[ "$env" == *awesome* ]] || pgrep -xu "$RUN_USER" awesome >/dev/null 2>&1; then
        printf 'awesome\n'; return 0
    fi
    if [[ "$env" == *bspwm* ]] || pgrep -xu "$RUN_USER" bspwm >/dev/null 2>&1; then
        printf 'bspwm\n'; return 0
    fi
    if [[ "$env" == *openbox* ]] || pgrep -xu "$RUN_USER" openbox >/dev/null 2>&1; then
        printf 'openbox\n'; return 0
    fi
    if [[ "$env" == *i3* ]] || pgrep -xu "$RUN_USER" i3 >/dev/null 2>&1; then
        printf 'i3\n'; return 0
    fi

    if [[ "${SESSION_TYPE}" == "wayland" ]]; then
        printf 'wayland-generic\n'
    else
        printf 'x11-generic\n'
    fi
}

# -----------------------------------------------------------------------------
#  menu and sources
# -----------------------------------------------------------------------------

list_wallpapers() {
    local f
    for f in "$WALL_DIR"/*; do
        [[ -f "$f" ]] || continue
        is_valid_image "$f" && printf '%s\n' "$f"
    done | sort
}

pick_with_launcher() {
    local prompt="$1"

    if command_exists wofi && [[ "$(detect_session)" == "wayland" ]]; then
        wofi --dmenu --prompt "$prompt" --width 450 --height 350 2>/dev/null
        return 0
    fi

    if command_exists fuzzel && [[ "$(detect_session)" == "wayland" ]]; then
        fuzzel --dmenu --prompt "$prompt" 2>/dev/null
        return 0
    fi

    if command_exists bemenu; then
        bemenu -p "$prompt" 2>/dev/null
        return 0
    fi

    if command_exists rofi; then
        rofi -dmenu -p "$prompt" 2>/dev/null
        return 0
    fi

    if command_exists dmenu; then
        dmenu -p "$prompt" 2>/dev/null
        return 0
    fi

    return 1
}

select_target() {
    local mode="${1:-menu}"
    local target=""

    case "$mode" in
        menu)
            target="$(list_wallpapers | pick_with_launcher "$DEFAULT_MENU_PROMPT" || true)"
            ;;
        random)
            mapfile -t __themes_random_items < <(list_wallpapers)
            if ((${#__themes_random_items[@]})); then
                target="${__themes_random_items[RANDOM % ${#__themes_random_items[@]}]}"
            fi
            ;;
        last)
            target="$(jq -r '.last_applied.wallpaper // empty' "$HISTORY_FILE" 2>/dev/null || true)"
            ;;
        list)
            list_wallpapers
            return 0
            ;;
        *)
            target="$mode"
            ;;
    esac

    printf '%s\n' "$target"
}

resolve_target() {
    local target="$1"

    if [[ -f "$target" ]]; then
        printf '%s\n' "$target"
        return 0
    fi

    if [[ -f "$WALL_DIR/$target" ]]; then
        printf '%s\n' "$WALL_DIR/$target"
        return 0
    fi

    return 1
}

# -----------------------------------------------------------------------------
#  wallpaper + terminal sync
# -----------------------------------------------------------------------------

apply_wallpaper() {
    local image="$1"
    local session_type="$2"

    case "$session_type" in
        wayland)
            if command_exists swww; then
                if ! pgrep -xu "$RUN_USER" swww-daemon >/dev/null 2>&1; then
                    swww-daemon >/dev/null 2>&1 &
                    sleep 0.25
                fi
                swww img "$image" --transition-type wipe --transition-step 90 --transition-fps 60 >/dev/null 2>&1 && return 0
            fi

            if command_exists hyprctl && command_exists hyprpaper; then
                hyprctl hyprpaper preload "$image" >/dev/null 2>&1 || true
                hyprctl hyprpaper wallpaper ",$image" >/dev/null 2>&1 && return 0
            fi
            ;&
        x11|x11-generic|wayland-generic)
            if command_exists xwallpaper; then
                xwallpaper --zoom "$image" >/dev/null 2>&1 && return 0
            fi
            if command_exists feh; then
                feh --bg-fill "$image" >/dev/null 2>&1 && return 0
            fi
            if command_exists nitrogen; then
                nitrogen --set-zoom-fill "$image" --save >/dev/null 2>&1 && return 0
            fi
            if command_exists gsettings; then
                gsettings set org.gnome.desktop.background picture-uri "file://$image" >/dev/null 2>&1 || true
                gsettings set org.gnome.desktop.background picture-uri-dark "file://$image" >/dev/null 2>&1 || true
                return 0
            fi
            return 0
            ;;
        *)
            return 0
            ;;
    esac
}

refresh_terminals() {
    local seq_file="$PYWAL_CACHE/sequences"
    [[ -f "$seq_file" ]] || return 0

    local uid
    uid="$(id -u)"

    local tty owner
    for tty in /dev/pts/[0-9]*; do
        [[ -w "$tty" ]] || continue
        owner="$(stat -c '%u' "$tty" 2>/dev/null || true)"
        [[ "$owner" == "$uid" ]] || continue
        cat "$seq_file" > "$tty" 2>/dev/null || true
    done

    if [[ -w /dev/tty ]]; then
        cat "$seq_file" > /dev/tty 2>/dev/null || true
    fi
}

patch_cava() {
    local json="$1"
    local config="${XDG_CONFIG_HOME}/cava/config"

    [[ -f "$config" ]] || return 0
    command_exists jq || return 0

    local c1 c2
    c1="$(jq -r '.colors.color1 // "#89b4fa"' "$json" 2>/dev/null || printf '#89b4fa')"
    c2="$(jq -r '.colors.color2 // "#94e2d5"' "$json" 2>/dev/null || printf '#94e2d5')"

    local tmp
    tmp="$(mktemp "${TEMP_DIR}/cava.XXXXXX")"

    cp -- "$config" "$tmp"
    sed -i \
        -e 's/^gradient *=.*/gradient = 1/' \
        -e 's/^gradient_count *=.*/gradient_count = 2/' \
        -e "s/^gradient_color_1 *=.*/gradient_color_1 = '$c1'/" \
        -e "s/^gradient_color_2 *=.*/gradient_color_2 = '$c2'/" \
        -e '/^gradient_color_[3-6] *=.*/d' \
        "$tmp" 2>/dev/null || true

    mv -- "$tmp" "$config"

    pkill -USR1 cava 2>/dev/null || true
}

store_history() {
    local wallpaper="$1" de="$2" session="$3"
    local ts
    ts="$(date -Is)"

    local tmp
    tmp="$(mktemp "${TEMP_DIR}/history.XXXXXX")"

    jq \
        --arg wallpaper "$wallpaper" \
        --arg de "$de" \
        --arg session "$session" \
        --arg ts "$ts" \
        '
        .last_applied = {
            wallpaper: $wallpaper,
            desktop: $de,
            session: $session,
            applied_at: $ts
        } |
        .history = ((.history // []) + [{
            wallpaper: $wallpaper,
            desktop: $de,
            session: $session,
            applied_at: $ts
        }])[-50:]
        ' "$HISTORY_FILE" > "$tmp" 2>/dev/null || {
            rm -f -- "$tmp"
            return 0
        }

    mv -- "$tmp" "$HISTORY_FILE"
}

sync_hyprland() {
    local json="$1"

    command_exists hyprctl || return 0
    local active inactive shadow
    active="$(jq -r '.colors.color1 // "#89b4fa"' "$json" 2>/dev/null || printf '#89b4fa')"
    inactive="$(jq -r '.colors.color0 // "#1e1e2e"' "$json" 2>/dev/null || printf '#1e1e2e')"
    shadow="$(jq -r '.colors.color8 // "#000000"' "$json" 2>/dev/null || printf '#000000')"

    hyprctl --batch \
        "keyword general:col.active_border rgba($(trim_hash "$active"))ff rgba($(trim_hash "$inactive"))aa 45deg" \
        "keyword general:col.inactive_border rgba($(trim_hash "$inactive"))aa" \
        "keyword decoration:col.shadow rgba($(trim_hash "$shadow"))40" \
        >/dev/null 2>&1 || true
}

sync_sway() {
    local json="$1"
    command_exists swaymsg || return 0

    local accent bg fg
    accent="$(jq -r '.colors.color1 // "#89b4fa"' "$json" 2>/dev/null || printf '#89b4fa')"
    bg="$(jq -r '.special.background // "#1e1e2e"' "$json" 2>/dev/null || printf '#1e1e2e')"
    fg="$(jq -r '.special.foreground // "#cdd6f4"' "$json" 2>/dev/null || printf '#cdd6f4')"

    swaymsg "client.focused $accent $accent $fg $bg $accent" >/dev/null 2>&1 || true
}

sync_i3() {
    local json="$1"
    command_exists i3-msg || return 0

    local accent bg fg
    accent="$(jq -r '.colors.color1 // "#89b4fa"' "$json" 2>/dev/null || printf '#89b4fa')"
    bg="$(jq -r '.special.background // "#1e1e2e"' "$json" 2>/dev/null || printf '#1e1e2e')"
    fg="$(jq -r '.special.foreground // "#cdd6f4"' "$json" 2>/dev/null || printf '#cdd6f4')"

    local i3_config="${XDG_CONFIG_HOME}/i3/config"
    if [[ -f "$i3_config" ]]; then
        perl -0pi -e 's/^set \$accent .*/set \$accent '"$accent"'/m; s/^set \$bg .*/set \$bg '"$bg"'/m; s/^set \$fg .*/set \$fg '"$fg"'/m' "$i3_config" 2>/dev/null || true
        i3-msg reload >/dev/null 2>&1 || true
    fi
}

sync_gnome() {
    local json="$1"
    command_exists gsettings || return 0

    local accent
    accent="$(jq -r '.colors.color4 // "#94e2d5"' "$json" 2>/dev/null || printf '#94e2d5')"
    gsettings set org.gnome.desktop.interface accent-color "${accent#\#}" >/dev/null 2>&1 || true
}

sync_xfce() {
    local json="$1"
    command_exists xfconf-query || return 0

    local theme icon_theme
    theme="$(jq -r '.special.name // "Adwaita"' "$json" 2>/dev/null || printf 'Adwaita')"
    icon_theme="$(jq -r '.special.icon_theme // "Adwaita"' "$json" 2>/dev/null || printf 'Adwaita')"

    xfconf-query -c xsettings -p /Net/ThemeName -s "$theme" >/dev/null 2>&1 || true
    xfconf-query -c xsettings -p /Net/IconThemeName -s "$icon_theme" >/dev/null 2>&1 || true
}

sync_openbox() {
    command_exists openbox && openbox --reconfigure >/dev/null 2>&1 || true
}

sync_awesome() {
    local json="$1"
    local c1 bg
    c1="$(jq -r '.colors.color1 // "#89b4fa"' "$json" 2>/dev/null || printf '#89b4fa')"
    bg="$(jq -r '.special.background // "#1e1e2e"' "$json" 2>/dev/null || printf '#1e1e2e')"

    local theme_file="${THEME_CACHE}/awesome_theme.lua"
    cat > "$theme_file" <<EOF
-- Auto-generated by themes-core
local theme = {}
theme.bg_focus = "$c1"
theme.fg_focus = "$bg"
return theme
EOF

    if command_exists awesome-client; then
        printf 'awesome.restart()\n' | awesome-client >/dev/null 2>&1 || true
    fi
}

sync_bspwm() {
    local json="$1"
    command_exists bspc || return 0

    local active inactive
    active="$(jq -r '.colors.color1 // "#89b4fa"' "$json" 2>/dev/null || printf '#89b4fa')"
    inactive="$(jq -r '.colors.color8 // "#1e1e2e"' "$json" 2>/dev/null || printf '#1e1e2e')"

    bspc config focused_border_color "$active" >/dev/null 2>&1 || true
    bspc config normal_border_color "$inactive" >/dev/null 2>&1 || true
}

sync_xresources() {
    local json="$1"
    local xres="${PYWAL_CACHE}/colors.Xresources"
    [[ -f "$xres" ]] || return 0
    command_exists xrdb || return 0
    xrdb -merge "$xres" >/dev/null 2>&1 || true
}

sync_desktop() {
    local json="$1" de="$2"

    case "$de" in
        hyprland) sync_hyprland "$json" ;;
        sway) sync_sway "$json" ;;
        i3) sync_i3 "$json" ;;
        gnome) sync_gnome "$json" ;;
        xfce) sync_xfce "$json" ;;
        openbox) sync_openbox ;;
        awesome) sync_awesome "$json" ;;
        bspwm) sync_bspwm "$json" ;;
        *) sync_xresources "$json" ;;
    esac
}

apply_pipeline() {
    local target="$1"
    local session
    session="$(detect_session)"
    local de
    de="$(detect_desktop_environment)"

    local json_file="${PYWAL_CACHE}/colors.json"
    local image

    image="$(resolve_target "$target" || true)"
    if [[ -z "$image" ]]; then
        local msg="TEMA NÃO-APLICADO: arquivo inválido"
        log_error "$msg"
        notify_result err "$msg"
        exit 1
    fi

    if ! is_valid_image "$image"; then
        local msg="TEMA NÃO-APLICADO: imagem inválida"
        log_error "$msg"
        notify_result err "$msg"
        exit 1
    fi

    if ! wal -i "$image" -q >/dev/null 2>&1; then
        local msg="TEMA NÃO-APLICADO: falha ao gerar paleta"
        log_error "$msg"
        notify_result err "$msg"
        exit 1
    fi

    [[ -f "$json_file" ]] || {
        local msg="TEMA NÃO-APLICADO: colors.json não encontrado"
        log_error "$msg"
        notify_result err "$msg"
        exit 1
    }

    apply_wallpaper "$image" "$session"
    sync_desktop "$json_file" "$de"
    patch_cava "$json_file"
    refresh_terminals
    sleep "$TERM_REFRESH_DELAY"
    store_history "$image" "$de" "$session"

    notify_result ok "TEMA APLICADO COM ÊXITO"
}

# -----------------------------------------------------------------------------
#  CLI
# -----------------------------------------------------------------------------

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [opções] [arquivo|nome|modo]

Modos:
  menu      abre seletor (padrão)
  random    aplica um wallpaper aleatório
  last      aplica o último wallpaper aplicado
  list      lista wallpapers disponíveis
  caminho   aplica arquivo específico

Opções:
  --menu         abre seletor
  --random       seleciona aleatório
  --last         reaplica o último
  --list         lista wallpapers
  --apply PATH   aplica caminho específico
  --root PATH    define root do tema para esta execução
  --help         mostra ajuda

Exemplos:
  $SCRIPT_NAME
  $SCRIPT_NAME --random
  $SCRIPT_NAME --apply ~/Pictures/wall.png
  $SCRIPT_NAME --root ~/.local/share/themes-core
EOF
}

parse_args() {
    local mode="menu"
    local apply_target=""
    local root_override=""

    while (($#)); do
        case "$1" in
            --menu) mode="menu" ;;
            --random) mode="random" ;;
            --last) mode="last" ;;
            --list) mode="list" ;;
            --apply)
                shift
                [[ $# -gt 0 ]] || { echo "missing argument for --apply" >&2; exit 1; }
                apply_target="$1"
                ;;
            --root)
                shift
                [[ $# -gt 0 ]] || { echo "missing argument for --root" >&2; exit 1; }
                root_override="$1"
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            --*)
                echo "unknown option: $1" >&2
                exit 1
                ;;
            *)
                if [[ -z "$apply_target" && "$mode" == "menu" ]]; then
                    apply_target="$1"
                fi
                ;;
        esac
        shift || true
    done

    if [[ -n "$root_override" ]]; then
        printf '%s\n' "$root_override" > "$THEME_POINTER"
        load_theme_paths
    fi

    case "$mode" in
        list)
            list_wallpapers
            exit 0
            ;;
        menu)
            if [[ -z "$apply_target" ]]; then
                apply_target="$(select_target menu || true)"
            fi
            ;;
        random)
            apply_target="$(select_target random || true)"
            ;;
        last)
            apply_target="$(select_target last || true)"
            ;;
    esac

    [[ -n "$apply_target" ]] || exit 0
    apply_pipeline "$apply_target"
}

# -----------------------------------------------------------------------------
#  traps
# -----------------------------------------------------------------------------

_handle_error() {
    local line="$1" cmd="$2" status="${3:-1}"
    local msg="TEMA NÃO-APLICADO: erro na linha $line"
    log_file "ERROR" "line=$line status=$status cmd=$cmd"
    notify_result err "$msg"
    exit "$status"
}

_handle_interrupt() {
    notify_result err "TEMA NÃO-APLICADO: operação cancelada"
    exit 130
}

_cleanup() {
    local exit_code="$?"
    rm -f -- "$LOCK_FILE" 2>/dev/null || true
    rm -rf -- "$TEMP_DIR" 2>/dev/null || true

    if [[ "$exit_code" -ne 0 ]]; then
        log_file "ERROR" "exit_code=$exit_code"
    fi
}

acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local old_pid
        old_pid="$(<"$LOCK_FILE" 2>/dev/null || true)"
        if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
            echo "themes-core already running" >&2
            exit 1
        fi
        rm -f -- "$LOCK_FILE" 2>/dev/null || true
    fi

    printf '%s\n' "$$" > "$LOCK_FILE"
}

main() {
    acquire_lock
    init_core
    validate_dependencies
    CURRENT_WM="$(detect_desktop_environment)"

    log_verbose "session=${SESSION_TYPE} de=${CURRENT_WM}"
    parse_args "$@"
}

main "$@"
