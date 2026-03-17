#!/bin/bash
# Mic voice-reactive level bar for waybar
# Uses arecord + sox to capture actual mic input levels
# Uses theme colors from Omarchy

# Source theme colors
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/theme-colors.sh"

# Check if muted
is_muted() {
  pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | grep -q 'yes'
}

# Get mic input level (0-100) from a tiny audio sample
get_mic_level() {
  # Capture 0.1s of audio and analyze with sox
  local level=$(timeout 0.15 arecord -D pulse -f S16_LE -r 44100 -c 1 -t raw 2>/dev/null | \
                sox -t raw -r 44100 -b 16 -c 1 -e signed - -n stat 2>&1 | \
                awk '/RMS.*amplitude/ {print $3}')
  
  if [[ -z $level ]] || [[ $level == "0.000000" ]]; then
    echo "0"
  else
    # Scale RMS amplitude (typically 0.0-0.3 for normal speech) to 0-100
    awk "BEGIN {
      val = $level * 400
      if (val > 100) val = 100
      printf \"%.0f\", val
    }"
  fi
}

# Build bar visualization (10 segments)
build_bar() {
  local level=$1
  local bars=""
  local filled=$((level / 10))
  
  for i in {1..10}; do
    if (( i <= filled )); then
      bars+="█"
    else
      bars+="░"
    fi
  done
  
  echo "$bars"
}

# Main loop - continuous output for waybar
while true; do
  if is_muted; then
    icon="󰍭"
    color="$COLOR_PRIMARY"
    bars="░░░░░░░░░░"
    level="0"
    class="muted"
  else
    icon="󰍬"
    color="$COLOR_ACCENT"
    level=$(get_mic_level)
    bars=$(build_bar "$level")
    class="active"
  fi
  
  text="[ <span color='${color}'>${icon}</span> <span color='${COLOR_FOREGROUND}'>${bars}</span> <span color='${color}'>${level}%</span> ]"
  
  printf '{"text": "%s", "class": "%s"}\n' "$text" "$class"
  
  sleep 0.1
done
