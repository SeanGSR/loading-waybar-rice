#!/bin/bash
# Network module: WiFi/Ethernet icon + download/upload speeds
# Uses theme colors from Omarchy

# Source theme colors
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/theme-colors.sh"

get_active_interface() {
  ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}'
}

get_wifi_icon() {
  local interface=$1
  local signal=$(iw dev "$interface" link 2>/dev/null | awk '/signal/ {print $2}')
  
  if [[ -z $signal ]]; then
    echo "󰤨"
    return
  fi
  
  if (( signal >= -50 )); then
    echo "󰤨"
  elif (( signal >= -60 )); then
    echo "󰤥"
  elif (( signal >= -70 )); then
    echo "󰤢"
  elif (( signal >= -80 )); then
    echo "󰤟"
  else
    echo "󰤯"
  fi
}

format_speed() {
  local bytes=$1
  if (( bytes >= 1073741824 )); then
    awk "BEGIN {printf \"%.1fG\", $bytes/1073741824}"
  elif (( bytes >= 1048576 )); then
    awk "BEGIN {printf \"%.1fM\", $bytes/1048576}"
  elif (( bytes >= 1024 )); then
    awk "BEGIN {printf \"%.0fK\", $bytes/1024}"
  else
    echo "0K"
  fi
}

global_state="/tmp/waybar_network_state"
interface=$(get_active_interface)

if [[ -z $interface ]]; then
  printf '{"text": "[ <span color='"'"'%s'"'"'>󰤮</span> ]", "class": "disconnected", "tooltip": "Disconnected"}\n' "$COLOR_PRIMARY"
  exit 0
fi

if [[ -d "/sys/class/net/$interface/wireless" ]]; then
  icon=$(get_wifi_icon "$interface")
  connection_type="WiFi"
  ssid=$(iw dev "$interface" link 2>/dev/null | awk '/SSID/ {print $2}')
else
  icon="󰀂"
  connection_type="Ethernet"
  ssid="Wired"
fi

rx_bytes=$(cat "/sys/class/net/$interface/statistics/rx_bytes" 2>/dev/null || echo 0)
tx_bytes=$(cat "/sys/class/net/$interface/statistics/tx_bytes" 2>/dev/null || echo 0)
current_time=$(date +%s%N)

if [[ -f $global_state ]]; then
  read -r prev_rx prev_tx prev_time < "$global_state"
else
  prev_rx=$rx_bytes
  prev_tx=$tx_bytes
  prev_time=$current_time
fi

time_diff=$(( (current_time - prev_time) / 1000000 ))
if (( time_diff > 0 )); then
  rx_speed=$(( (rx_bytes - prev_rx) * 1000 / time_diff ))
  tx_speed=$(( (tx_bytes - prev_tx) * 1000 / time_diff ))
else
  rx_speed=0
  tx_speed=0
fi

(( rx_speed < 0 )) && rx_speed=0
(( tx_speed < 0 )) && tx_speed=0

echo "$rx_bytes $tx_bytes $current_time" > "$global_state"

rx_fmt=$(format_speed $rx_speed)
tx_fmt=$(format_speed $tx_speed)

ip_addr=$(ip -4 addr show "$interface" 2>/dev/null | awk '/inet / {print $2}' | cut -d'/' -f1)
tooltip="${connection_type}: ${ssid}\\nIP: ${ip_addr}\\nInterface: ${interface}"

text="[ <span color='${COLOR_ACCENT}'>${icon}</span> <span color='${COLOR_FOREGROUND}'>↓${rx_fmt} ↑${tx_fmt}</span> ]"

printf '{"text": "%s", "class": "connected", "tooltip": "%s"}\n' "$text" "$tooltip"
