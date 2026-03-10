#!/bin/bash
# themeset.sh
# Usage: themeset [-v] [--list] <theme>
#   -v       Verbose: show logs and errors
#   --list   List all available themes

VERBOSE=0
if [ "$1" = "-v" ]; then
    VERBOSE=1
    shift
fi

err() {
    [ "$VERBOSE" -eq 1 ] && echo "[ERROR] $1" >&2
}
info() {
    [ "$VERBOSE" -eq 1 ] && echo "[INFO] $1"
}

# --list: show all available themes
if [ "$1" = "--list" ]; then
    echo "Available themes:"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    declare -A seen
    for dir in \
        "$HOME/.config/themes" \
        "/usr/share/themeset" \
        "$SCRIPT_DIR/themes"
    do
        if [ -d "$dir" ]; then
            for theme in "$dir"/*/; do
                name="$(basename "$theme")"
                if [ -z "${seen[$name]}" ]; then
                    echo "  $name"
                    seen[$name]=1
                fi
            done
        fi
    done
    exit 0
fi

THEME=$1
if [ -z "$THEME" ]; then
    echo "Usage: themeset [-v] [--list] <theme>"
    exit 1
fi

# User-local themes folder
USER_THEMES_DIR="$HOME/.config/themes"
THEME_DIR="$USER_THEMES_DIR/$THEME"
mkdir -p "$USER_THEMES_DIR" || { err "Failed to create $USER_THEMES_DIR"; exit 1; }

# Determine source theme (local > installed > dev)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEV_THEME_DIR="$SCRIPT_DIR/themes/$THEME"
INSTALLED_THEME_DIR="/usr/share/themeset/$THEME"

if [ -d "$THEME_DIR" ]; then
    SOURCE_THEME="$THEME_DIR"
elif [ -d "$INSTALLED_THEME_DIR" ]; then
    SOURCE_THEME="$INSTALLED_THEME_DIR"
elif [ -d "$DEV_THEME_DIR" ]; then
    SOURCE_THEME="$DEV_THEME_DIR"
else
    echo "Theme '$THEME' not found. Run 'themeset --list' to see available themes."
    exit 1
fi

# Copy theme only if it doesn't exist locally yet
if [ "$SOURCE_THEME" != "$THEME_DIR" ]; then
    info "Copying theme '$THEME' to $USER_THEMES_DIR..."
    cp -r "$SOURCE_THEME" "$USER_THEMES_DIR/" || { err "Failed to copy theme from '$SOURCE_THEME' to '$USER_THEMES_DIR'"; exit 1; }
else
    info "Using local theme '$THEME' from $USER_THEMES_DIR."
fi

if [ ! -d "$THEME_DIR" ]; then
    err "Theme directory '$THEME_DIR' does not exist. Check that the theme folder is named exactly '$THEME'."
    exit 1
fi

# Helper: create parent dirs and symlink
make_symlink() {
    local src="$1"
    local dest="$2"
    if [ ! -f "$src" ]; then
        err "Source file not found, skipping symlink: $src"
        return 1
    fi
    local dest_dir
    dest_dir="$(dirname "$dest")"
    if [ ! -d "$dest_dir" ]; then
        mkdir -p "$dest_dir" || { err "Failed to create directory: $dest_dir"; return 1; }
    fi
    ln -sf "$src" "$dest" && info "Symlinked: $dest -> $src" || err "Failed to symlink: $dest -> $src"
}

# Hyprland — safely add source line if not already present
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
SOURCE_LINE="source = ~/.config/hypr/theme.conf"
mkdir -p "$HOME/.config/hypr" || { err "Failed to create ~/.config/hypr"; }
make_symlink "$THEME_DIR/hypr.conf" "$HOME/.config/hypr/theme.conf"
if [ ! -f "$HYPR_CONF" ] || ! grep -qF "$SOURCE_LINE" "$HYPR_CONF"; then
    echo "" >> "$HYPR_CONF"
    echo "# Added by rthemes" >> "$HYPR_CONF"
    echo "$SOURCE_LINE" >> "$HYPR_CONF"
    info "Added source line to hyprland.conf."
else
    info "Source line already present in hyprland.conf, skipping."
fi

# Waybar
make_symlink "$THEME_DIR/waybar.css" "$HOME/.config/waybar/style.css"
if [ -f "$THEME_DIR/waybar.jsonc" ]; then
    make_symlink "$THEME_DIR/waybar.jsonc" "$HOME/.config/waybar/config.jsonc"
fi

# Wallpaper — accept any image file in theme dir
WALLPAPER=""
for f in "$THEME_DIR"/*; do
    case "${f##*.}" in
        jpg|jpeg|png|webp|gif)
            WALLPAPER="$f"
            break
            ;;
    esac
done

if [ -n "$WALLPAPER" ]; then
    if ! pgrep -x swww-daemon > /dev/null 2>&1; then
        info "swww-daemon not running, starting it..."
        nohup swww-daemon > /dev/null 2>&1 < /dev/null &
        sleep 1
    fi
    if pgrep -x swww-daemon > /dev/null 2>&1; then
        info "Setting wallpaper: $WALLPAPER"
        swww img "$WALLPAPER" > /dev/null 2>&1 || err "swww failed to set wallpaper."
    else
        err "swww-daemon not running. Wallpaper will not be applied."
    fi
else
    info "No wallpaper image found in theme, skipping."
fi

# Reload Hyprland
info "Reloading Hyprland..."
hyprctl reload > /dev/null 2>&1 || err "hyprctl reload failed (is Hyprland running?)"

# Restart Waybar
info "Restarting Waybar..."
pgrep -x waybar > /dev/null 2>&1 && pkill waybar && sleep 0.5
waybar > /dev/null 2>&1 &
sleep 0.5
if ! pgrep -x waybar > /dev/null 2>&1; then
    err "Waybar failed to start."
else
    info "Waybar started."
fi

echo "Theme '$THEME' applied."
