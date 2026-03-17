#!/bin/bash
# loading-waybar-rice uninstaller
# Restores default Omarchy waybar

set -e

WAYBAR_DIR="$HOME/.config/waybar"
HYPR_DIR="$HOME/.config/hypr"
OMARCHY_DIR="$HOME/.config/omarchy"

echo "=== loading-waybar-rice uninstaller ==="
echo ""

# Find most recent backup
BACKUP=$(ls -td "$WAYBAR_DIR.backup."* 2>/dev/null | head -1)

if [ -n "$BACKUP" ] && [ -d "$BACKUP" ]; then
    read -p "Restore backup from $BACKUP? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo "Restoring backup..."
        rm -rf "$WAYBAR_DIR"
        mv "$BACKUP" "$WAYBAR_DIR"
    fi
else
    echo "No backup found. Removing custom config..."
    rm -f "$WAYBAR_DIR/config.jsonc"
    rm -f "$WAYBAR_DIR/style.css"
    rm -rf "$WAYBAR_DIR/scripts"
    rm -rf "$WAYBAR_DIR/sounds"
fi

# Remove theme-set hook
if [ -f "$OMARCHY_DIR/hooks/theme-set" ]; then
    echo "Removing theme-set hook..."
    rm -f "$OMARCHY_DIR/hooks/theme-set"
fi

# Remove mic toggle keybinding
if [ -f "$HYPR_DIR/bindings.conf" ]; then
    if grep -q "loading-waybar-rice" "$HYPR_DIR/bindings.conf"; then
        echo "Removing mic toggle keybinding..."
        sed -i '/# Mic toggle (loading-waybar-rice)/d' "$HYPR_DIR/bindings.conf"
        sed -i '/mic-toggle.sh/d' "$HYPR_DIR/bindings.conf"
    fi
fi

# Kill cava and restart waybar
pkill -9 cava 2>/dev/null || true
sleep 0.3

if command -v omarchy-restart-waybar &> /dev/null; then
    omarchy-restart-waybar
fi

echo ""
echo "=== Uninstall complete ==="
echo "Waybar has been reset. You may need to log out and back in for full effect."
