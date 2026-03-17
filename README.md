# loading-waybar-rice

A custom Waybar configuration for [Omarchy](https://omarchy.com) with Cava audio visualizer, system monitoring, and theme-adaptive colors.

Inspired by [Dionysus](https://github.com/pewdiepie-archdaemon/dionysus) waybar theme.

## Features

- **Cava Audio Visualizer** - Horizontal bars reacting to audio with volume percentage
- **System Monitoring** - CPU, GPU (with VRAM), RAM, Disk usage, and Coolant temperature
- **Network Speeds** - WiFi/Ethernet icon with live download/upload speeds
- **Microphone Toggle** - Ctrl+M with audio feedback (beep sounds)
- **Theme-Adaptive Colors** - Automatically matches your Omarchy theme
- **Bracketed Modules** - Clean `[ module ]` styling

## One-Command Install

```bash
git clone https://github.com/YOUR_USERNAME/loading-waybar-rice.git && cd loading-waybar-rice && ./install.sh
```

## Manual Install

```bash
git clone https://github.com/YOUR_USERNAME/loading-waybar-rice.git
cd loading-waybar-rice
chmod +x install.sh
./install.sh
```

## Dependencies

- `cava` - Audio visualizer
- `waybar` - Status bar
- `pipewire-pulse` / `pulseaudio` - Audio control
- `lm_sensors` - Temperature monitoring
- `nvidia-utils` - GPU monitoring (optional, for NVIDIA cards)

Install on Arch:
```bash
sudo pacman -S cava waybar pipewire-pulse lm_sensors nvidia-utils
```

## Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+M` | Toggle microphone mute (with sound feedback) |
| Click on volume | Open audio mixer |
| Scroll on volume | Adjust volume |

## Module Layout

```
[ workspaces ] [ window title ]          [ cava ███░░ 70% ] [ CPU GPU RAM Disk Coolant ] [ Net ↓↑ ] [ Mic ] [ Tray ] [ Clock ]
```

## Customization

### Colors
Colors are automatically pulled from your Omarchy theme at:
```
~/.config/omarchy/current/theme/colors.toml
```

Change your Omarchy theme and waybar updates automatically!

### Scripts
All scripts are in `~/.config/waybar/scripts/`:
- `cava-volume.sh` - Audio visualizer + volume
- `sysinfo.sh` - System monitoring
- `network.sh` - Network speeds
- `mic.sh` - Microphone status
- `mic-toggle.sh` - Toggle mic with sound

## Uninstall

```bash
cd loading-waybar-rice
./uninstall.sh
```

This restores your previous waybar config from backup.

## Credits

- [Omarchy](https://omarchy.com) - The base Linux distribution
- [Dionysus](https://github.com/pewdiepie-archdaemon/dionysus) - Inspiration for the bracketed module style
