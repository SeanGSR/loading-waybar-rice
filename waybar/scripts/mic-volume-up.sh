#!/bin/bash
# Increase mic volume by 5%, max 150%
current=$(wpctl get-volume @DEFAULT_SOURCE@ 2>/dev/null | awk '{printf "%.0f", $2 * 100}')
[[ -z $current ]] && current=0
new_vol=$((current + 5))
(( new_vol > 150 )) && new_vol=150
# Convert to decimal for wpctl (e.g., 150% = 1.50)
wpctl set-volume @DEFAULT_SOURCE@ $(awk "BEGIN {printf \"%.2f\", $new_vol/100}")
