#!/bin/bash
#
# Omarchy Workspace Backgrounds Installer
# Per-workspace wallpapers with dynamic theme color injection
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/omarchy/backups/workspace-backgrounds-$(date +%Y%m%d-%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║       Omarchy Workspace Backgrounds Installer              ║"
echo "║  Per-workspace wallpapers + Dynamic theme color injection  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if Omarchy is installed
if [ ! -d "$HOME/.config/omarchy" ]; then
    error "Omarchy not found. Please install Omarchy first."
fi

# Check dependencies
info "Checking dependencies..."
MISSING_DEPS=""
for cmd in swaybg wallust hyprctl notify-send; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_DEPS="$MISSING_DEPS $cmd"
    fi
done

if [ -n "$MISSING_DEPS" ]; then
    warn "Missing dependencies:$MISSING_DEPS"
    echo "  Install them with your package manager before using."
fi

# Create backup directory
info "Creating backup directory..."
mkdir -p "$BACKUP_DIR"

# Backup existing files
info "Backing up existing files..."

if [ -f "$HOME/.local/bin/omarchy-workspace-bg-daemon" ]; then
    cp "$HOME/.local/bin/omarchy-workspace-bg-daemon" "$BACKUP_DIR/" 2>/dev/null || true
fi
if [ -f "$HOME/.local/bin/omarchy-workspace-bg-config" ]; then
    cp "$HOME/.local/bin/omarchy-workspace-bg-config" "$BACKUP_DIR/" 2>/dev/null || true
fi
if [ -f "$HOME/.local/bin/omarchy-theme-bg-next" ]; then
    cp "$HOME/.local/bin/omarchy-theme-bg-next" "$BACKUP_DIR/" 2>/dev/null || true
fi
if [ -f "$HOME/.config/omarchy/hooks/apply-theme-colors" ]; then
    cp "$HOME/.config/omarchy/hooks/apply-theme-colors" "$BACKUP_DIR/" 2>/dev/null || true
fi
if [ -f "$HOME/.config/hypr/autostart.conf" ]; then
    cp "$HOME/.config/hypr/autostart.conf" "$BACKUP_DIR/" 2>/dev/null || true
fi

success "Backup created at: $BACKUP_DIR"

# Create directories
info "Creating directories..."
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/omarchy/hooks"
mkdir -p "$HOME/.config/omarchy/workspace-backgrounds"

# Install bin scripts
info "Installing scripts..."
cp "$SCRIPT_DIR/bin/omarchy-workspace-bg-daemon" "$HOME/.local/bin/"
cp "$SCRIPT_DIR/bin/omarchy-workspace-bg-config" "$HOME/.local/bin/"
cp "$SCRIPT_DIR/bin/omarchy-theme-bg-next" "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/omarchy-workspace-bg-daemon"
chmod +x "$HOME/.local/bin/omarchy-workspace-bg-config"
chmod +x "$HOME/.local/bin/omarchy-theme-bg-next"
success "Installed bin scripts"

# Install hook
info "Installing apply-theme-colors hook..."
cp "$SCRIPT_DIR/hooks/apply-theme-colors" "$HOME/.config/omarchy/hooks/"
chmod +x "$HOME/.config/omarchy/hooks/apply-theme-colors"
success "Installed apply-theme-colors hook"

# Patch autostart.conf
info "Patching autostart.conf..."
AUTOSTART_FILE="$HOME/.config/hypr/autostart.conf"

if [ -f "$AUTOSTART_FILE" ]; then
    # Add pkill swaybg if not present
    if ! grep -q "pkill swaybg" "$AUTOSTART_FILE"; then
        # Add at the beginning
        echo -e "exec-once = pkill swaybg\n$(cat "$AUTOSTART_FILE")" > "$AUTOSTART_FILE"
        success "Added 'pkill swaybg' to autostart.conf"
    else
        info "'pkill swaybg' already in autostart.conf"
    fi

    # Add daemon startup if not present
    if ! grep -q "omarchy-workspace-bg-daemon" "$AUTOSTART_FILE"; then
        echo "exec-once = omarchy-workspace-bg-daemon" >> "$AUTOSTART_FILE"
        success "Added daemon to autostart.conf"
    else
        info "Daemon already in autostart.conf"
    fi
else
    # Create new autostart.conf
    cat > "$AUTOSTART_FILE" << 'EOF'
exec-once = pkill swaybg
exec-once = omarchy-workspace-bg-daemon
EOF
    success "Created autostart.conf"
fi

# Create default config if not exists
CONFIG_FILE="$HOME/.config/omarchy/workspace-backgrounds/config"
if [ ! -f "$CONFIG_FILE" ]; then
    info "Creating default configuration..."
    cat > "$CONFIG_FILE" << 'EOF'
# Workspace Backgrounds Configuration
# Format: workspace_number|/path/to/wallpaper.jpg
# Example:
# 1|~/Pictures/workspace1.jpg
# 2|~/Pictures/workspace2.jpg
EOF
    success "Created default config at $CONFIG_FILE"
fi

# Create default overrides if not exists
OVERRIDES_FILE="$HOME/.config/omarchy/workspace-backgrounds/overrides.conf"
if [ ! -f "$OVERRIDES_FILE" ]; then
    info "Creating default overrides configuration..."
    cat > "$OVERRIDES_FILE" << 'EOF'
# Omarchy Color Overrides Configuration
#
# Use this file to override specific color mappings.
# By default, colors are mapped dynamically from the wallpaper.
# You can force specific theme elements to use fixed colors or different mapping.
#
# Available dynamic variables:
# $bg, $fg, $cursor, $accent
# $color0 - $color15 (ANSI colors)
#
# Target variables (Omarchy Palette):
# oma0 - oma3: Background layers
# oma4 - oma6: Foreground/Text layers
# oma7 - oma10: Accent/Highlight layers
# oma11 - oma15: Semantic colors (error, success, etc)
#
# Examples:
#
# 1. Force the main background to always be pure black:
# oma0="#000000"
#
# 2. Make the primary accent (oma8) use the wallpaper's red color instead of accent color:
# oma8="$color1"
#
# 3. Make the bar background (oma0) slightly transparent (if supported):
# oma0="#1e1e2e"
#
# 4. Use a fixed hex color for critical errors:
# oma11="#ff0000"

# --- Your Overrides Below ---
EOF
    success "Created overrides config at $OVERRIDES_FILE"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                 Installation Complete!                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo ""
echo "  1. Configure wallpapers for each workspace:"
echo "     ${BLUE}omarchy-workspace-bg-config${NC}"
echo ""
echo "  2. Restart Hyprland or run the daemon manually:"
echo "     ${BLUE}omarchy-workspace-bg-daemon${NC}"
echo ""
echo "  3. Switch workspaces to see per-workspace wallpapers!"
echo ""
echo "Features:"
echo "  - Per-workspace wallpapers"
echo "  - Dynamic color extraction from wallpaper (via wallust)"
echo "  - Theme colors update automatically when switching workspaces"
echo "  - Theme switching preserves your wallpaper choices"
echo ""
echo "To uninstall: ${YELLOW}bash uninstall.sh${NC}"
echo ""
