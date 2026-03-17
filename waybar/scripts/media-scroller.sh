#!/bin/bash

CACHE_DIR="/home/loading/.cache/waybar-media"
mkdir -p "$CACHE_DIR"

STATE_FILE="$CACHE_DIR/scroll.state"

title=$(playerctl metadata title 2>/dev/null)
status=$(playerctl status 2>/dev/null)

if [ -z "$title" ]; then
    echo "󰝚 No media"
    rm -f "$STATE_FILE"
    exit 0
fi

if [ "$title" != "$(cat "$CACHE_DIR/title" 2>/dev/null)" ]; then
    echo "$title" > "$CACHE_DIR/title"
    echo "0" > "$STATE_FILE"
fi
echo "$title" > "$CACHE_DIR/title"

icon=$(echo "$status" | grep -q Playing && echo '⏸' || echo '▶')
max_len=20

if [ ${#title} -le $max_len ]; then
    echo "$icon $title"
    exit 0
fi

offset=$(cat "$STATE_FILE" 2>/dev/null || echo "0")
offset=$(( (offset + 1) % ${#title} ))

scrolled="${title:$offset:$max_len}"
if [ $((offset + max_len)) -gt ${#title} ]; then
    remaining=$(( ${#title} - offset ))
    scrolled="${title:$offset:$remaining} ${title:0:$((max_len - remaining))}"
fi

echo "$icon $scrolled"
echo "$offset" > "$STATE_FILE"