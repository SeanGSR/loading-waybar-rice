#!/bin/bash
# Cava audio visualizer with horizontal bars + volume display
# Uses theme colors from Omarchy

# Source theme colors
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/theme-colors.sh"

config_file="/tmp/waybar_cava_volume_config_$$"
trap "rm -f $config_file" EXIT

cat > "$config_file" << 'EOF'
[general]
bars = 10
framerate = 30

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

get_volume_info() {
  local vol_raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{ print $2 }')
  local vol_int=$(awk "BEGIN { printf \"%.0f\", $vol_raw * 100 }" 2>/dev/null)
  local is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q MUTED && echo true || echo false)
  
  local icon
  if [[ $is_muted == "true" ]]; then
    icon="󰖁"
    vol_int=0
  elif (( vol_int < 30 )); then
    icon="󰕿"
  elif (( vol_int < 70 )); then
    icon="󰖀"
  else
    icon="󰕾"
  fi
  
  local class
  if [[ $is_muted == "true" ]]; then
    class="muted"
  else
    class="normal"
  fi
  
  echo "$icon|$vol_int|$is_muted|$class"
}

exec 2>/dev/null
cava -p "$config_file" 2>/dev/null | while IFS=';' read -ra nums; do
  IFS='|' read -r icon vol_int is_muted class <<< "$(get_volume_info)"
  
  total=0
  for n in "${nums[@]}"; do
    (( total += n ))
  done
  
  if [[ $is_muted == "true" ]]; then
    filled=0
  else
    filled=$(( total * 10 / 70 ))
    (( filled > 10 )) && filled=10
  fi
  empty=$(( 10 - filled ))
  
  bar=""
  for ((i=0; i<filled; i++)); do
    bar+="█"
  done
  for ((i=0; i<empty; i++)); do
    bar+="░"
  done
  
  if [[ $is_muted == "true" ]]; then
    text="[ <span color='${COLOR_PRIMARY}'>${icon} ${bar} ${vol_int}%</span> ]"
  else
    text="[ <span color='${COLOR_ACCENT}'>${icon}</span> <span color='${COLOR_FOREGROUND}'>${bar} ${vol_int}%</span> ]"
  fi
  
  printf '{"text": "%s", "class": "%s"}\n' "$text" "$class"
done
