#!/bin/bash
# Toggle mic mute and play appropriate beep sound

SOUNDS_DIR="$HOME/.config/waybar/sounds"

# Toggle mute
pactl set-source-mute @DEFAULT_SOURCE@ toggle

# Check new state and play sound
if pactl get-source-mute @DEFAULT_SOURCE@ | grep -q 'yes'; then
  pw-play "$SOUNDS_DIR/mic-muted.wav" &
else
  pw-play "$SOUNDS_DIR/mic-unmuted.wav" &
fi

# Signal waybar to instantly refresh the mic module (signal 11)
pkill -RTMIN+11 waybar
