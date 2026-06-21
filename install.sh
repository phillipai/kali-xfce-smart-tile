#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")" && pwd)"
script_src="$repo_dir/bin/xfce-smart-tile"
script_dst="$HOME/.local/bin/xfce-smart-tile"

echo "Kali XFCE Smart Tile installer"
echo "Target: XFCE/X11 desktops"
echo

if [[ ! -f "$script_src" ]]; then
  echo "Missing script: $script_src" >&2
  exit 1
fi

for dependency in awk wmctrl xdotool xprop xrandr xfconf-query; do
  if ! command -v "$dependency" >/dev/null 2>&1; then
    echo "Missing dependency: $dependency" >&2
    echo "Debian/Kali/Ubuntu: sudo apt install wmctrl xdotool" >&2
    echo "Arch: sudo pacman -S wmctrl xdotool" >&2
    exit 127
  fi
done

mkdir -p "$HOME/.local/bin"
cp "$script_src" "$script_dst"
chmod +x "$script_dst"
echo "Installed: $script_dst"

echo "Applying XFCE keyboard shortcuts..."

# Provider order: commands first, then xfwm4
xfconf-query -c xfce4-keyboard-shortcuts -p /providers -a -t string -s commands -t string -s xfwm4 2>/dev/null || true

# Super arrow commands
xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Super>Up' --create -t string -s "$script_dst up"
xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Super>Down' -s "$script_dst down" 2>/dev/null || \
  xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Super>Down' --create -t string -s "$script_dst down"
xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Super>Left' -s "$script_dst left" 2>/dev/null || \
  xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Super>Left' --create -t string -s "$script_dst left"
xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Super>Right' -s "$script_dst right" 2>/dev/null || \
  xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Super>Right' --create -t string -s "$script_dst right"

# Monitor transfer: Shift+Super+Arrow
xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Shift><Super>Left' --create -t string -s "$script_dst monitor-left"
xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Shift><Super>Right' --create -t string -s "$script_dst monitor-right"
xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Shift><Super>Up' --create -t string -s "$script_dst monitor-up"
xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Shift><Super>Down' --create -t string -s "$script_dst monitor-down"

# Also register reversed modifier order for XFCE compatibility
xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Super><Shift>Left' --create -t string -s "$script_dst monitor-left"
xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/<Super><Shift>Right' --create -t string -s "$script_dst monitor-right"

# Disable built-in XFWM handlers so they don't intercept
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Super>Up' --create -t string -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Super>Down' --create -t string -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Super>Left' --create -t string -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Super>Right' --create -t string -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Shift><Super>Left' --create -t string -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Shift><Super>Right' --create -t string -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Super><Shift>Left' --create -t string -s ''
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Super><Shift>Right' --create -t string -s ''

# Reload XFCE settings daemon to pick up changes
xfsettingsd --replace >/dev/null 2>&1 &

echo "Shortcuts applied."
echo
echo "Done. Super+Arrow smart tiling is installed."
