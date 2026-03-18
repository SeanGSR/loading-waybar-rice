#!/bin/bash
# Read colors from current Omarchy theme
# Source this file in other waybar scripts to get theme colors

THEME_COLORS="$HOME/.config/omarchy/current/theme/colors.toml"

get_color() {
  grep "^[[:space:]]*$1[[:space:]]*=" "$THEME_COLORS" 2>/dev/null | head -1 | cut -d'"' -f2
}

# Export theme colors
COLOR_FOREGROUND=$(get_color "foreground")
COLOR_BACKGROUND=$(get_color "background")
COLOR_ACCENT=$(get_color "accent")
COLOR_PRIMARY=$(get_color "color4")      # Purple - primary accent
COLOR_SECONDARY=$(get_color "color5")    # Secondary accent  
COLOR_SUCCESS=$(get_color "color2")      # Green - success/positive
COLOR_MUTED=$(get_color "color8")        # Dim/muted
COLOR_BRIGHT=$(get_color "color15")      # Brightest

# Status level colors (for sysinfo, etc.)
COLOR_LOW=$(get_color "accent")          # Blue - low usage (good)
COLOR_MED=$(get_color "color5")          # Pink - medium usage (warning)
COLOR_HIGH=$(get_color "color1")         # Red - high usage (critical)

# Fallback defaults if theme file not found
[[ -z $COLOR_FOREGROUND ]] && COLOR_FOREGROUND="#cdd6f4"
[[ -z $COLOR_BACKGROUND ]] && COLOR_BACKGROUND="#1e1e2e"
[[ -z $COLOR_ACCENT ]] && COLOR_ACCENT="#89b4fa"
[[ -z $COLOR_PRIMARY ]] && COLOR_PRIMARY="#89b4fa"
[[ -z $COLOR_SECONDARY ]] && COLOR_SECONDARY="#f5c2e7"
[[ -z $COLOR_SUCCESS ]] && COLOR_SUCCESS="#a6e3a1"
[[ -z $COLOR_MUTED ]] && COLOR_MUTED="#585b70"
[[ -z $COLOR_BRIGHT ]] && COLOR_BRIGHT="#a6adc8"
[[ -z $COLOR_LOW ]] && COLOR_LOW="#89b4fa"
[[ -z $COLOR_MED ]] && COLOR_MED="#f5c2e7"
[[ -z $COLOR_HIGH ]] && COLOR_HIGH="#f38ba8"
