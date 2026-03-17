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

# Fallback defaults if theme file not found
[[ -z $COLOR_FOREGROUND ]] && COLOR_FOREGROUND="#DCC9BC"
[[ -z $COLOR_BACKGROUND ]] && COLOR_BACKGROUND="#1A1515"
[[ -z $COLOR_ACCENT ]] && COLOR_ACCENT="#AE3F82"
[[ -z $COLOR_PRIMARY ]] && COLOR_PRIMARY="#756D94"
[[ -z $COLOR_SECONDARY ]] && COLOR_SECONDARY="#7B3D79"
[[ -z $COLOR_SUCCESS ]] && COLOR_SUCCESS="#959A6B"
[[ -z $COLOR_MUTED ]] && COLOR_MUTED="#453636"
[[ -z $COLOR_BRIGHT ]] && COLOR_BRIGHT="#ffe9c7"
