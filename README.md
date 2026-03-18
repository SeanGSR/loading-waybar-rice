# loading-waybar-rice

A custom Waybar configuration for [Omarchy](https://omarchy.com) with Cava audio visualizer, system monitoring, and theme-adaptive colors.

Inspired by [Dionysus](https://github.com/pewdiepie-archdaemon/dionysus) waybar theme.

## Features

- **Cava Audio Visualizer** - Horizontal bars reacting to audio with volume percentage
- **Mic Voice Level** - Real-time voice-reactive level bar with percentage
- **Battery Bar** - Visual battery indicator with charging status (for laptops)
- **System Monitoring** - CPU, GPU (with VRAM), RAM, Disk usage, and Coolant temperature
- **Network Speeds** - WiFi/Ethernet icon with live download/upload speeds
- **Microphone Toggle** - Ctrl+M with audio feedback (beep sounds)
- **Theme-Adaptive Colors** - Automatically matches your Omarchy theme
- **Bracketed Modules** - Clean `[ module ]` styling

## One-Command Install

```bash
git clone https://github.com/SeanGSR/loading-waybar-rice.git && cd loading-waybar-rice && ./install.sh
```

## Manual Install

```bash
git clone https://github.com/SeanGSR/loading-waybar-rice.git
cd loading-waybar-rice
chmod +x install.sh
./install.sh
```

## Dependencies

- `cava` - Audio visualizer
- `waybar` - Status bar
- `pipewire` / `wireplumber` - Audio control (uses wpctl)
- `lm_sensors` - Temperature monitoring
- `sox` - Mic level analysis
- `alsa-utils` - Audio recording (for mic level)
- `nvidia-utils` - GPU monitoring (optional, for NVIDIA cards)

Install on Arch:
```bash
sudo pacman -S cava waybar pipewire wireplumber lm_sensors sox alsa-utils nvidia-utils
```

## Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+M` | Toggle microphone mute (with sound feedback) |
| Click on volume | Open audio mixer |
| Scroll on volume | Adjust volume |

## Module Layout

```
Left:   [ Omarchy ] [ CPU GPU RAM Disk Coolant ] [ Tray ]
Center: [ Workspaces ]
Right:  [ Net ↓↑ ] [ Mic ███░░ 30% ] [ Bluetooth ] [ Cava ███░░ 70% ] [ Battery ███░░ 60% ] [ Tuesday 17/03 March • 14:30:45 ]
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
- `mic-level.sh` - Voice-reactive mic level bar
- `battery.sh` - Battery bar visualization
- `sysinfo.sh` - System monitoring
- `network.sh` - Network speeds
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
