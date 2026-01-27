# Omarchy Workspace Backgrounds

A lightweight utility for Hyprland users (specifically designed for Omarchy) to set different wallpapers for each workspace with smooth transitions.

## Features

- 🖼️ **Per-Workspace Wallpapers**: Assign a unique background image to every workspace.
- ✨ **Smooth Transitions**: Uses `swww` for seamless crossfading between backgrounds.
- 🛠️ **TUI Configuration**: Includes a terminal user interface (`omarchy-workspace-bg-config`) for easy setup.
- 🚀 **Performance**: Efficient event-driven daemon that only wakes up on workspace changes.

## Prerequisites

- **Hyprland**: The tiling window manager.
- **swww**: For wallpaper rendering and animations.
- **socat**: To listen to Hyprland socket events.
- **jq**: For JSON parsing.
- **gum**: For the TUI configuration tool.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/omarchy-workspace-bg.git
   cd omarchy-workspace-bg
   ```

2. Run the installer:
   ```bash
   ./install.sh
   ```

   This will:
   - Check for dependencies.
   - Install scripts to `~/.local/bin`.
   - Setup the configuration directory at `~/.config/omarchy/workspace-bg`.
   - Add the daemon to your Hyprland autostart (optional).

## Usage

### Configuration Tool

Run the configuration tool to manage your wallpapers:

```bash
omarchy-workspace-bg-config
```

From here you can:
- Select a workspace ID (e.g., 1, 2, 3).
- Browse and select an image file.
- View your current mapping.
- Restart the daemon.

### Manual Configuration

You can also edit the configuration file directly at `~/.config/omarchy/workspace-bg/config.conf`:

```ini
1=/path/to/image1.jpg
2=/path/to/image2.png
# ...
```

### The Daemon

The daemon `omarchy-workspace-bg-daemon` runs in the background. It automatically starts `swww-daemon` if it's not running.

To reload the configuration manually without the TUI:
```bash
omarchy-workspace-bg-daemon --reload
```

## License

MIT
