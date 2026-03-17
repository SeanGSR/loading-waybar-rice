#!/bin/bash
# System info module: CPU, GPU, RAM, Disk, Coolant temps
# Uses theme colors from Omarchy

# Source theme colors
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/theme-colors.sh"

# CPU usage (btop-style delta over 1 second for accuracy)
read -r _ user1 nice1 sys1 idle1 iowait1 irq1 sirq1 _ < /proc/stat
sleep 1
read -r _ user2 nice2 sys2 idle2 iowait2 irq2 sirq2 _ < /proc/stat
idle_delta=$((idle2 - idle1))
total_delta=$(( (user2+nice2+sys2+idle2+iowait2+irq2+sirq2) - (user1+nice1+sys1+idle1+iowait1+irq1+sirq1) ))
cpu_usage=$((100 * (total_delta - idle_delta) / total_delta))

# CPU temp (AMD k10temp)
cpu_temp=$(sensors 2>/dev/null | awk '/Tctl/ {gsub(/[+°C]/,"",$2); printf "%.0f", $2}')
[[ -z $cpu_temp ]] && cpu_temp="0"

# GPU (NVIDIA)
gpu_info=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used --format=csv,noheader,nounits 2>/dev/null)
if [[ -n $gpu_info ]]; then
  gpu_usage=$(echo "$gpu_info" | cut -d',' -f1 | tr -d ' ')
  gpu_temp=$(echo "$gpu_info" | cut -d',' -f2 | tr -d ' ')
  gpu_mem=$(echo "$gpu_info" | cut -d',' -f3 | tr -d ' ')
  if (( gpu_mem >= 1024 )); then
    gpu_mem_fmt=$(awk "BEGIN {printf \"%.1fG\", $gpu_mem/1024}")
  else
    gpu_mem_fmt="${gpu_mem}M"
  fi
else
  gpu_usage="0"
  gpu_temp="0"
  gpu_mem_fmt="--"
fi

# RAM used
ram_used=$(free -h | awk '/Mem:/ {print $3}' | sed 's/Gi/G/' | sed 's/Mi/M/')
ram_percent=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')

# Disk usage (root partition)
disk_usage=$(df -h / | awk 'NR==2 {gsub(/%/,"",$5); print $5}')

# Coolant temp (NZXT Kraken)
coolant=$(sensors 2>/dev/null | awk '/Coolant temp/ {gsub(/[+°C]/,"",$3); printf "%.0f", $3}')
[[ -z $coolant ]] && coolant="0"

# Determine overall color based on worst metric (using theme colors)
color="$COLOR_FOREGROUND"
class="normal"

if (( cpu_usage > 80 )) || (( gpu_usage > 80 )) || (( cpu_temp > 80 )) || (( gpu_temp > 80 )) || (( ram_percent > 90 )) || (( coolant > 40 )); then
  color="$COLOR_SECONDARY"
  class="critical"
elif (( cpu_usage > 50 )) || (( gpu_usage > 50 )) || (( cpu_temp > 60 )) || (( gpu_temp > 60 )) || (( ram_percent > 70 )) || (( coolant > 35 )); then
  color="$COLOR_PRIMARY"
  class="warning"
fi

# Build output text
text="[ <span color='${color}'>󰍛 ${cpu_usage}% ${cpu_temp}°C</span> | <span color='${color}'>󰢮 ${gpu_usage}% ${gpu_temp}°C ${gpu_mem_fmt}</span> | <span color='${color}'>󰘚 ${ram_used}</span> | <span color='${color}'>󰋊 ${disk_usage}%</span> | <span color='${color}'>󰔏 ${coolant}°C</span> ]"

# Tooltip
tooltip="CPU: ${cpu_usage}% @ ${cpu_temp}°C\\nGPU: ${gpu_usage}% @ ${gpu_temp}°C (VRAM: ${gpu_mem_fmt})\\nRAM: ${ram_used} (${ram_percent}%)\\nDisk: ${disk_usage}%\\nCoolant: ${coolant}°C"

printf '{"text": "%s", "class": "%s", "tooltip": "%s"}\n' "$text" "$class" "$tooltip"
