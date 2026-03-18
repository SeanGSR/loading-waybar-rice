#!/bin/bash
# Cava audio visualizer overlapped with volume bar
# Uses different characters: ▓ for cava, █ for volume above cava, ░ for empty
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
  
  # Calculate volume level (scaled to 150% = 10 bars)
  if [[ $is_muted == "true" ]]; then
    vol_bars=0
    display_vol="0"
  else
    vol_bars=$((vol_int / 15))
    (( vol_bars > 10 )) && vol_bars=10
    display_vol="$vol_int"
  fi
  
  # Calculate cava level
  total=0
  for n in "${nums[@]}"; do
    (( total += n ))
  done
  
  if [[ $is_muted == "true" ]]; then
    cava_bars=0
  else
    cava_bars=$(( total * 10 / 70 ))
    (( cava_bars > 10 )) && cava_bars=10
  fi
  
  # Build overlapped bar:
  # - ▓ (cava active, within volume) - accent color
  # - █ (volume above cava level) - foreground color  
  # - ░ (empty, above volume) - dim
  bar=""
  for ((i=1; i<=10; i++)); do
    if (( i <= vol_bars )); then
      if (( i <= cava_bars )); then
        # Cava active within volume range - accent color
        bar+="<span color='${COLOR_ACCENT}'>▓</span>"
      else
        # Volume but no cava - foreground color
        bar+="<span color='${COLOR_FOREGROUND}'>█</span>"
      fi
    else
      # Empty (above volume level)
      bar+="<span color='${COLOR_FOREGROUND}'>░</span>"
    fi
  done
  
  # Build output
  if [[ $is_muted == "true" ]]; then
    text="[ <span color='${COLOR_PRIMARY}'>${icon}</span> ${bar} <span color='${COLOR_PRIMARY}'>${display_vol}%</span> ]"
  else
    text="[ <span color='${COLOR_ACCENT}'>${icon}</span> ${bar} <span color='${COLOR_ACCENT}'>${display_vol}%</span> ]"
  fi
  
  printf '{"text": "%s", "class": "%s"}\n' "$text" "$class"
done
