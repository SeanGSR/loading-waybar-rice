#!/bin/bash
# Battery bar visualization for waybar
# Uses theme colors from Omarchy

# Source theme colors
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/theme-colors.sh"

# Find battery
BAT_PATH=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1)

# No battery found - output empty and exit
if [[ -z $BAT_PATH ]]; then
  printf '{"text": "", "class": "no-battery"}\n'
  exit 0
fi

# Read battery info
capacity=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo "0")
status=$(cat "$BAT_PATH/status" 2>/dev/null || echo "Unknown")

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

# Get icon based on status and level
get_icon() {
  local level=$1
  local status=$2
  
  case $status in
    Charging)
      if (( level >= 90 )); then echo "󰂅"
      elif (( level >= 80 )); then echo "󰂋"
      elif (( level >= 70 )); then echo "󰂊"
      elif (( level >= 60 )); then echo "󰢞"
      elif (( level >= 50 )); then echo "󰂉"
      elif (( level >= 40 )); then echo "󰢝"
      elif (( level >= 30 )); then echo "󰂈"
      elif (( level >= 20 )); then echo "󰂇"
      elif (( level >= 10 )); then echo "󰂆"
      else echo "󰢜"
      fi
      ;;
    Full)
      echo "󰁹"
      ;;
    *)  # Discharging or Unknown
      if (( level >= 90 )); then echo "󰁹"
      elif (( level >= 80 )); then echo "󰂂"
      elif (( level >= 70 )); then echo "󰂁"
      elif (( level >= 60 )); then echo "󰂀"
      elif (( level >= 50 )); then echo "󰁿"
      elif (( level >= 40 )); then echo "󰁾"
      elif (( level >= 30 )); then echo "󰁽"
      elif (( level >= 20 )); then echo "󰁼"
      elif (( level >= 10 )); then echo "󰁻"
      else echo "󰁺"
      fi
      ;;
  esac
}

# Determine color based on level and status
get_color() {
  local level=$1
  local status=$2
  
  if [[ $status == "Charging" ]] || [[ $status == "Full" ]]; then
    echo "$COLOR_ACCENT"
  elif (( level <= 10 )); then
    echo "$COLOR_SECONDARY"  # Critical
  elif (( level <= 20 )); then
    echo "$COLOR_PRIMARY"    # Warning
  else
    echo "$COLOR_FOREGROUND"
  fi
}

# Get class for CSS
get_class() {
  local level=$1
  local status=$2
  
  if [[ $status == "Charging" ]]; then
    echo "charging"
  elif [[ $status == "Full" ]]; then
    echo "full"
  elif (( level <= 10 )); then
    echo "critical"
  elif (( level <= 20 )); then
    echo "warning"
  else
    echo "normal"
  fi
}

icon=$(get_icon "$capacity" "$status")
bars=$(build_bar "$capacity")
color=$(get_color "$capacity" "$status")
class=$(get_class "$capacity" "$status")

# Tooltip with more info
power=$(cat "$BAT_PATH/power_now" 2>/dev/null || echo "0")
power_w=$(awk "BEGIN {printf \"%.1f\", $power/1000000}")
tooltip="${status}\\n${capacity}%\\n${power_w}W"

text="[ <span color='${color}'>${icon}</span> <span color='${COLOR_FOREGROUND}'>${bars}</span> <span color='${color}'>${capacity}%</span> ]"

printf '{"text": "%s", "class": "%s", "tooltip": "%s"}\n' "$text" "$class" "$tooltip"
