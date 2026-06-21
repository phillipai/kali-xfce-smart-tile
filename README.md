# Kali XFCE Smart Tile

## Demonstration

![Kali XFCE Smart Tile demonstration](assets/demo.gif)

## Abstract

Kali XFCE Smart Tile is a lightweight X11 window-management helper that adds predictable keyboard-driven tiling to Kali Linux XFCE. It provides half-screen tiling, quarter-screen tiling, native monitor fill, multi-monitor transfer, and minimize/restore behavior using standard Linux X11 utilities.

The project is designed for Kali Linux first, while remaining portable to other X11-based Linux distributions such as Debian, Ubuntu, Xubuntu, and Arch Linux.

## Motivation

Default Kali Linux XFCE window management is functional, but the default `Super + Arrow` behavior is limited for users who work with several windows at once.

Common workflow examples include:

- terminal and browser side by side
- documentation beside a tool window
- packet capture beside notes
- security tooling beside command output
- four-window layouts on large displays
- multi-monitor research and operations workflows

This project solves that problem without replacing XFCE or installing a full tiling window manager.

## Tested System

The implementation was developed and tested on a standard XFCE/X11 desktop environment.

```text
Distribution: Kali Linux
Desktop environment: XFCE
Window manager: XFWM4
Display server: X11
Monitor layout: multi-monitor
Display types tested: horizontal ultrawide and vertical portrait monitor
```

No private hostnames, usernames, hardware serials, or personal environment details are required for use.

## Compatibility

Primary target:

```text
Kali Linux XFCE on X11
```

Expected compatible systems:

```text
Debian XFCE on X11
Ubuntu / Xubuntu XFCE on X11
Arch Linux XFCE on X11
Other EWMH-compatible X11 desktops
```

Not supported:

```text
Wayland
```

Wayland intentionally restricts global window control, so tools such as `xdotool` and `wmctrl` cannot provide the same behavior there.

## Features

- Native-feeling `Super + Arrow` tiling
- Full monitor fill using the window manager's native maximize behavior
- Top-half and bottom-half tiling
- Left-half and right-half tiling
- Top-left, top-right, bottom-left, and bottom-right quarter tiling
- Repeated same-side key toggles between half and quarter layouts
- `Super + Down` minimizes only after the window is already bottom-tiled
- `Super + Up` restores the last window minimized by this helper
- Multi-monitor transfer with `Shift + Super + Arrow`
- Per-monitor geometry calculation
- Frame-aware placement to keep titlebars visible
- Panel-aware behavior where supported by the window manager
- Lightweight shell implementation

## Dependencies

Required X11 utilities:

```text
wmctrl
xdotool
xprop
xrandr
awk
xfconf-query
```

Debian, Kali, Ubuntu, Xubuntu:

```bash
sudo apt install wmctrl xdotool
```

Arch Linux:

```bash
sudo pacman -S wmctrl xdotool
```

## Installation

Clone or download this repository, then run:

```bash
bash install.sh
```

The installer will:

- copy `bin/xfce-smart-tile` to `~/.local/bin/xfce-smart-tile`
- make the helper executable
- register XFCE keyboard shortcuts
- prioritize command shortcuts over conflicting XFWM defaults
- disable conflicting XFWM default bindings for the same keys
- reload XFCE settings

## Manual Installation

If you prefer manual setup:

```bash
mkdir -p ~/.local/bin
cp bin/xfce-smart-tile ~/.local/bin/xfce-smart-tile
chmod +x ~/.local/bin/xfce-smart-tile
```

Then bind the following commands in XFCE Keyboard Settings.

```text
Super+Up            ~/.local/bin/xfce-smart-tile up
Super+Down          ~/.local/bin/xfce-smart-tile down
Super+Left          ~/.local/bin/xfce-smart-tile left
Super+Right         ~/.local/bin/xfce-smart-tile right
Shift+Super+Left    ~/.local/bin/xfce-smart-tile monitor-left
Shift+Super+Right   ~/.local/bin/xfce-smart-tile monitor-right
Shift+Super+Up      ~/.local/bin/xfce-smart-tile monitor-up
Shift+Super+Down    ~/.local/bin/xfce-smart-tile monitor-down
```

## Usage

### Main Window Controls

```text
Super+Up       top half, full monitor, or restore minimized window
Super+Down     bottom half; press again to minimize
Super+Left     left half; press again for left quarter; press again to return to left half
Super+Right    right half; press again for right quarter; press again to return to right half
```

### Multi-Monitor Controls

```text
Shift+Super+Left     move window to the monitor on the left and fill it
Shift+Super+Right    move window to the monitor on the right and fill it
Shift+Super+Up       move window to the monitor above and fill it
Shift+Super+Down     move window to the monitor below and fill it
```

## Layout Reference

### Full Monitor

```text
+---------------------------+
|                           |
|           FULL            |
|                           |
+---------------------------+
```

### Top Half

```text
+---------------------------+
|         TOP HALF          |
|                           |
+---------------------------+
|                           |
+---------------------------+
```

### Bottom Half

```text
+---------------------------+
|                           |
+---------------------------+
|        BOTTOM HALF        |
|                           |
+---------------------------+
```

### Left And Right Halves

```text
+-------------+-------------+
|             |             |
|  LEFT HALF  | RIGHT HALF  |
|             |             |
+-------------+-------------+
```

### Four-Quadrant Layout

```text
+-------------+-------------+
|  TOP LEFT   |  TOP RIGHT  |
|             |             |
+-------------+-------------+
| BOTTOM LEFT | BOTTOM RIGHT|
|             |             |
+-------------+-------------+
```

## Behavior Model

### Down Key

```text
Full monitor  -> bottom half
Any quarter   -> bottom half
Bottom half   -> minimize
Minimized     -> Super+Up restores it
```

### Up Key

```text
Full monitor  -> top half
Any quarter   -> top half
Top half      -> full monitor
Minimized     -> restore remembered window
```

### Left Key

```text
Full monitor       -> left half
Right half/quarter -> matching left side
Left half          -> top-left quarter
Left quarter       -> left half
```

### Right Key

```text
Full monitor      -> right half
Left half/quarter -> matching right side
Right half        -> top-right quarter
Right quarter     -> right half
```

## Multi-Monitor Model

The active window is assigned to the monitor containing the largest portion of that window. Tiling then occurs within that monitor only.

Monitor transfer uses physical monitor direction:

```text
Shift+Super+Left   -> nearest monitor to the left
Shift+Super+Right  -> nearest monitor to the right
Shift+Super+Up     -> nearest monitor above
Shift+Super+Down   -> nearest monitor below
```

The transferred window is then filled using native maximize behavior on the target monitor.

## Design Notes

The helper intentionally avoids hardcoded resolutions. It uses live X11 state:

```text
xrandr   monitor geometry
xprop    active window and frame metadata
wmctrl   EWMH state and native maximize/minimize behavior
xdotool  move, resize, activate, and minimize operations
```

Native maximize is used for full-monitor fill because the window manager already knows the correct frame-safe dimensions for each monitor. Explicit geometry is used for halves and quarters.

## Why This Should Exist By Default

Many Linux desktops provide basic window snapping, but do not provide a complete, predictable keyboard model for half-screen, quarter-screen, multi-monitor movement, and minimize/restore workflows.

Kali Linux users often work across several concurrent tools. A practical default tiling layer improves usability without changing the desktop environment or adding a heavy tiling window manager.

This project is intended as a small, auditable, practical improvement to the default XFCE desktop experience.

## Security And Privacy

The script does not send network traffic.

The script does not collect telemetry.

The script does not require root privileges for normal operation.

The script only queries local X11 window and monitor metadata to move the active window.

## Limitations

- X11 only
- Not compatible with Wayland
- Some applications enforce minimum window sizes
- Behavior depends on EWMH-compatible window-manager support

## License

MIT License. See `LICENSE`.

## Project Goal

The goal is simple: make Kali Linux XFCE window management feel native, fast, and complete using standard Linux tools.
