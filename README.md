# Omarchy Workspace Backgrounds

Per-workspace wallpapers with dynamic theme color injection for [Omarchy](https://github.com/omarchy/omarchy).

## Features

- **Per-workspace wallpapers** - Set different wallpapers for each Hyprland workspace
- **Dynamic color extraction** - Colors are extracted from the current wallpaper using `wallust`
- **Theme-aware** - Switch themes without losing your wallpaper configuration
- **Smart color injection** - Theme layouts/styling preserved, only colors update

## Requirements

- [Omarchy](https://github.com/omarchy/omarchy) installed
- `swaybg` - Wallpaper setter
- `wallust` - Color extraction from images
- `hyprctl` - Hyprland control utility
- `notify-send` - Desktop notifications (optional)

## Installation

```bash
git clone https://github.com/gojodennis/omarchy-workspace-bg.git
cd omarchy-workspace-bg
bash install.sh
```

## Usage

### Configure Wallpapers

Run the interactive configuration tool:

```bash
omarchy-workspace-bg-config
```

Or manually edit `~/.config/omarchy/workspace-backgrounds/config`. You can specify:
- A path to a single image file
- A path to a **directory** (a random wallpaper will be picked from it)

```
1|~/Pictures/workspace1.jpg
2|~/Pictures/wallpapers-folder/
3|~/Pictures/workspace3.mp4
```

### Slideshow Configuration

If you point a workspace to a **directory**, the daemon will pick a random wallpaper from it.
By default, it rotates the wallpaper every **10 minutes**.

You can change this interval by adding `SLIDESHOW_INTERVAL` to your config file:

```bash
# Rotate every 5 minutes
SLIDESHOW_INTERVAL=5

# Workspace mappings
1|~/Pictures/wallpapers-folder/
```

### Start the Daemon

The daemon starts automatically on login. To start manually:

```bash
omarchy-workspace-bg-daemon
```

### Commands

| Command | Description |
|---------|-------------|
| `omarchy-workspace-bg-config` | Interactive wallpaper configuration |
| `omarchy-workspace-bg-daemon` | Start the background daemon |
| `omarchy-workspace-bg-daemon --reload` | Reload configuration |
| `omarchy-theme-bg-next --force` | Manually cycle through theme wallpapers |

## How It Works

1. **Workspace Switch Detection**: The daemon monitors Hyprland workspace changes via `hyprctl`
2. **Wallpaper Application**: When you switch workspaces, the configured wallpaper is applied via `swaybg`
3. **Color Extraction**: `wallust` extracts a color palette from the new wallpaper
4. **Theme Update**: The `apply-theme-colors` hook injects these colors into your current theme's config files (Waybar, Walker, Neovim, terminals, etc.)

### Theme Preservation

When switching Omarchy themes:
- Theme **structure** (layouts, fonts, styling) changes to match the new theme
- Theme **colors** stay matched to your current workspace wallpaper
- Your per-workspace wallpaper configuration is preserved

## File Locations

| File | Purpose |
|------|---------|
| `~/.local/bin/omarchy-workspace-bg-daemon` | Main daemon script |
| `~/.local/bin/omarchy-workspace-bg-config` | Configuration tool |
| `~/.local/bin/omarchy-theme-bg-next` | Theme wallpaper override |
| `~/.config/omarchy/hooks/apply-theme-colors` | Color injection hook |
| `~/.config/omarchy/workspace-backgrounds/config` | Your wallpaper configuration |
| `~/.config/omarchy/workspace-backgrounds/overrides.conf` | Custom color overrides |

## Customization

### Color Overrides

You can override specific parts of the theme palette by editing `~/.config/omarchy/workspace-backgrounds/overrides.conf`. This is useful if you want to force a specific background color or change how accent colors are mapped.

Example `overrides.conf`:
```bash
# Force background to black
oma0="#000000"

# Make the primary accent use the wallpaper's red color
oma8="$color1"

# Custom hex color for critical alerts
oma11="#ff5555"
```

The palette uses variables `oma0` through `oma15`. See the file comments for details on what each variable controls.

## Uninstall

```bash
cd omarchy-workspace-bg
bash uninstall.sh
```

## Troubleshooting

### Wallpaper not changing
- Check if the daemon is running: `pgrep -f omarchy-workspace-bg-daemon`
- Check your config file syntax: `cat ~/.config/omarchy/workspace-backgrounds/config`
- Ensure wallpaper paths are valid and files exist

### Colors not updating
- Ensure `wallust` is installed and working
- Check if `~/.config/omarchy/current/theme/colors.toml` is being updated
- Run `~/.config/omarchy/hooks/apply-theme-colors` manually to check for errors

### Theme switching changes wallpaper
- This shouldn't happen with this installation. If it does, check that `~/.local/bin/omarchy-theme-bg-next` exists and is executable.

## License

MIT

## Credits

Built for use with [Omarchy](https://github.com/omarchy/omarchy).
