#!/bin/bash
# System info module: CPU, GPU, RAM, Disk, Coolant temps
# Each metric independently colored based on usage level
# Uses theme colors from Omarchy

# Source theme colors (includes COLOR_LOW, COLOR_MED, COLOR_HIGH)
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/theme-colors.sh"

# Get color based on value and thresholds
# Usage: get_status_color value low_threshold high_threshold
get_status_color() {
  local value=$1
  local low=$2
  local high=$3
  
  if (( value < low )); then
    echo "$COLOR_LOW"      # Blue - low usage
  elif (( value < high )); then
    echo "$COLOR_MED"      # Pink - medium usage
  else
    echo "$COLOR_HIGH"     # Red - high usage
  fi
}

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
  gpu_mem_gb=$(awk "BEGIN {printf \"%.0f\", $gpu_mem/1024}")
  if (( gpu_mem >= 1024 )); then
    gpu_mem_fmt=$(awk "BEGIN {printf \"%.1fG\", $gpu_mem/1024}")
  else
    gpu_mem_fmt="${gpu_mem}M"
  fi
else
  gpu_usage="0"
  gpu_temp="0"
  gpu_mem_gb="0"
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

# Calculate individual colors for each metric
# Thresholds: Low < threshold1, Medium < threshold2, High >= threshold2

# CPU: usage (30/70), temp (50/70)
cpu_usage_color=$(get_status_color $cpu_usage 30 70)
cpu_temp_color=$(get_status_color $cpu_temp 50 70)

# GPU: usage (30/70), temp (50/70), VRAM in GB (4/8)
gpu_usage_color=$(get_status_color $gpu_usage 30 70)
gpu_temp_color=$(get_status_color $gpu_temp 50 70)
gpu_mem_color=$(get_status_color $gpu_mem_gb 4 8)

# RAM: percentage (50/80)
ram_color=$(get_status_color $ram_percent 50 80)

# Disk: percentage (70/90)
disk_color=$(get_status_color $disk_usage 70 90)

# Coolant: temp (32/38)
coolant_color=$(get_status_color $coolant 32 38)

# Determine overall class based on worst metric (for CSS styling)
class="normal"
if (( cpu_usage >= 70 )) || (( gpu_usage >= 70 )) || (( cpu_temp >= 70 )) || (( gpu_temp >= 70 )) || (( ram_percent >= 80 )) || (( disk_usage >= 90 )) || (( coolant >= 38 )); then
  class="critical"
elif (( cpu_usage >= 30 )) || (( gpu_usage >= 30 )) || (( cpu_temp >= 50 )) || (( gpu_temp >= 50 )) || (( ram_percent >= 50 )) || (( disk_usage >= 70 )) || (( coolant >= 32 )); then
  class="warning"
fi

# Build output text with individual colors
text="[ <span color='${cpu_usage_color}'>󰍛 ${cpu_usage}%</span> <span color='${cpu_temp_color}'>${cpu_temp}°C</span>"
text+=" | <span color='${gpu_usage_color}'>󰢮 ${gpu_usage}%</span> <span color='${gpu_temp_color}'>${gpu_temp}°C</span> <span color='${gpu_mem_color}'>${gpu_mem_fmt}</span>"
text+=" | <span color='${ram_color}'>󰘚 ${ram_used}</span>"
text+=" | <span color='${disk_color}'>󰋊 ${disk_usage}%</span>"
text+=" | <span color='${coolant_color}'>󰔏 ${coolant}°C</span> ]"

# Tooltip
tooltip="CPU: ${cpu_usage}% @ ${cpu_temp}°C\\nGPU: ${gpu_usage}% @ ${gpu_temp}°C (VRAM: ${gpu_mem_fmt})\\nRAM: ${ram_used} (${ram_percent}%)\\nDisk: ${disk_usage}%\\nCoolant: ${coolant}°C"

printf '{"text": "%s", "class": "%s", "tooltip": "%s"}\n' "$text" "$class" "$tooltip"
