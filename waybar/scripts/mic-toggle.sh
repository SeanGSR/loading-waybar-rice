#!/bin/bash
# Toggle mic mute and play appropriate beep sound

SOUNDS_DIR="$HOME/.config/waybar/sounds"

# Toggle mute (using wpctl for PipeWire/wiremix compatibility)
wpctl set-mute @DEFAULT_SOURCE@ toggle

# Check new state and play sound
if wpctl get-volume @DEFAULT_SOURCE@ | grep -q MUTED; then
  pw-play "$SOUNDS_DIR/mic-muted.wav" &
else
  pw-play "$SOUNDS_DIR/mic-unmuted.wav" &
fi

# Signal waybar to instantly refresh the mic module (signal 11)
pkill -RTMIN+11 waybar
