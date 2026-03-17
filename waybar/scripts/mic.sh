#!/bin/bash
# Microphone mute status script for waybar
# Uses theme colors from Omarchy

# Source theme colors
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/theme-colors.sh"

if pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | grep -q 'yes'; then
  printf '{"text": "[ <span color='"'"'%s'"'"'>󰍭</span> ]", "class": "muted"}\n' "$COLOR_PRIMARY"
else
  printf '{"text": "[ <span color='"'"'%s'"'"'>󰍬</span> ]", "class": "unmuted"}\n' "$COLOR_ACCENT"
fi
