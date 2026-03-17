#!/bin/bash
# loading-waybar-rice installer
# One-command install for Omarchy systems

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
WAYBAR_DIR="$HOME/.config/waybar"
HYPR_DIR="$HOME/.config/hypr"
OMARCHY_DIR="$HOME/.config/omarchy"

echo "=== loading-waybar-rice installer ==="
echo ""

# Check for Omarchy
if [ ! -f "$OMARCHY_DIR/current/theme/colors.toml" ]; then
    echo "Warning: Omarchy theme not detected at $OMARCHY_DIR/current/theme/colors.toml"
    echo "This waybar config is designed for Omarchy. Colors may not work correctly."
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check dependencies
echo "Checking dependencies..."
MISSING=""
for cmd in cava waybar pactl pw-play sensors nvidia-smi; do
    if ! command -v $cmd &> /dev/null; then
        MISSING="$MISSING $cmd"
    fi
done

if [ -n "$MISSING" ]; then
    echo "Missing dependencies:$MISSING"
    echo ""
    echo "Install with: sudo pacman -S cava waybar pipewire-pulse lm_sensors nvidia-utils"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Backup existing config
if [ -d "$WAYBAR_DIR" ]; then
    BACKUP="$WAYBAR_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backing up existing waybar config to $BACKUP"
    cp -r "$WAYBAR_DIR" "$BACKUP"
fi

# Create directories
echo "Creating directories..."
mkdir -p "$WAYBAR_DIR/scripts"
mkdir -p "$WAYBAR_DIR/sounds"
mkdir -p "$OMARCHY_DIR/hooks"

# Copy waybar files
echo "Installing waybar config..."
cp "$REPO_DIR/waybar/config.jsonc" "$WAYBAR_DIR/"
cp "$REPO_DIR/waybar/style.css" "$WAYBAR_DIR/"
cp "$REPO_DIR/waybar/scripts/"*.sh "$WAYBAR_DIR/scripts/"
cp "$REPO_DIR/waybar/sounds/"*.wav "$WAYBAR_DIR/sounds/"

# Make scripts executable
chmod +x "$WAYBAR_DIR/scripts/"*.sh

# Install theme-set hook
echo "Installing theme-set hook..."
cp "$REPO_DIR/omarchy/hooks/theme-set" "$OMARCHY_DIR/hooks/"
chmod +x "$OMARCHY_DIR/hooks/theme-set"

# Add Hyprland keybinding for mic toggle (Ctrl+M)
echo "Checking Hyprland keybinding..."
if [ -f "$HYPR_DIR/bindings.conf" ]; then
    if ! grep -q "mic-toggle" "$HYPR_DIR/bindings.conf"; then
        echo "" >> "$HYPR_DIR/bindings.conf"
        echo "# Mic toggle (loading-waybar-rice)" >> "$HYPR_DIR/bindings.conf"
        echo 'bindd = CTRL, M, Mic toggle, exec, ~/.config/waybar/scripts/mic-toggle.sh' >> "$HYPR_DIR/bindings.conf"
        echo "Added Ctrl+M keybinding for mic toggle"
    else
        echo "Mic toggle keybinding already exists"
    fi
else
    echo "Warning: $HYPR_DIR/bindings.conf not found. Add this to your Hyprland config manually:"
    echo '  bindd = CTRL, M, Mic toggle, exec, ~/.config/waybar/scripts/mic-toggle.sh'
fi

# Kill any zombie cava processes and restart waybar
echo "Restarting waybar..."
pkill -9 cava 2>/dev/null || true
sleep 0.3

if command -v omarchy-restart-waybar &> /dev/null; then
    omarchy-restart-waybar
elif command -v killall &> /dev/null; then
    killall waybar 2>/dev/null || true
    sleep 0.3
    waybar &
fi

echo ""
echo "=== Installation complete! ==="
echo ""
echo "Features installed:"
echo "  - Cava audio visualizer with volume"
echo "  - System info (CPU, GPU, RAM, Disk, Coolant)"
echo "  - Network speeds (download/upload)"
echo "  - Mic toggle with Ctrl+M (with sound feedback)"
echo "  - Theme-adaptive colors"
echo ""
echo "Tip: Waybar auto-restarts when you change Omarchy themes!"
