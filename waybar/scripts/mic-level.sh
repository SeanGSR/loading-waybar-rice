#!/bin/bash
# Mic volume level bar for waybar
# Shows mic volume setting with bar visualization
# Uses theme colors from Omarchy

# Source theme colors
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/theme-colors.sh"

# Suppress errors
exec 2>/dev/null

# Get mic volume and mute status using wpctl (syncs with wiremix/PipeWire)
get_mic_info() {
  local vol_raw=$(wpctl get-volume @DEFAULT_SOURCE@ 2>/dev/null)
  local vol=$(echo "$vol_raw" | awk '{printf "%.0f", $2 * 100}')
  local muted=$(echo "$vol_raw" | grep -q MUTED && echo "true" || echo "false")
  [[ -z $vol ]] && vol=0
  echo "$vol|$muted"
}

# Build bar visualization (10 segments, scaled to 150% max)
build_bar() {
  local level=$1
  local bars=""
  # Scale: 150% = 10 bars, so each bar = 15%
  local filled=$((level / 15))
  (( filled > 10 )) && filled=10
  
  for i in {1..10}; do
    if (( i <= filled )); then
      bars+="█"
    else
      bars+="░"
    fi
  done
  
  echo "$bars"
}

# Get info
IFS='|' read -r volume is_muted <<< "$(get_mic_info)"

# Handle missing volume
[[ -z $volume ]] && volume=0

# Build output
if [[ $is_muted == "true" ]]; then
  icon="󰍭"
  color="$COLOR_PRIMARY"
  bars="░░░░░░░░░░"
  display_vol="0"
  class="muted"
else
  icon="󰍬"
  color="$COLOR_ACCENT"
  bars=$(build_bar "$volume")
  display_vol="$volume"
  class="active"
fi

text="[ <span color='${color}'>${icon}</span> <span color='${COLOR_FOREGROUND}'>${bars}</span> <span color='${color}'>${display_vol}%</span> ]"
printf '{"text": "%s", "class": "%s", "tooltip": "Mic Volume: %s%%"}\n' "$text" "$class" "$volume"
