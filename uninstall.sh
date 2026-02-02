#!/bin/bash
#
# Omarchy Workspace Backgrounds Uninstaller
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║       Omarchy Workspace Backgrounds Uninstaller            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Stop the daemon if running
info "Stopping daemon..."
pkill -f "omarchy-workspace-bg-daemon" 2>/dev/null || true
success "Daemon stopped"

# Remove bin scripts
info "Removing scripts..."
rm -f "$HOME/.local/bin/omarchy-workspace-bg-daemon"
rm -f "$HOME/.local/bin/omarchy-workspace-bg-config"
rm -f "$HOME/.local/bin/omarchy-theme-bg-next"
success "Removed bin scripts"

# Remove hook (restore original if backup exists)
info "Handling apply-theme-colors hook..."
LATEST_BACKUP=$(ls -td "$HOME/.config/omarchy/backups/workspace-backgrounds-"* 2>/dev/null | head -1)
if [ -n "$LATEST_BACKUP" ] && [ -f "$LATEST_BACKUP/apply-theme-colors" ]; then
    cp "$LATEST_BACKUP/apply-theme-colors" "$HOME/.config/omarchy/hooks/"
    success "Restored original apply-theme-colors from backup"
else
    warn "No backup found - leaving apply-theme-colors as is"
    warn "You may need to reinstall Omarchy or manually restore this file"
fi

# Clean autostart.conf
info "Cleaning autostart.conf..."
AUTOSTART_FILE="$HOME/.config/hypr/autostart.conf"
if [ -f "$AUTOSTART_FILE" ]; then
    # Remove our lines
    sed -i '/pkill swaybg/d' "$AUTOSTART_FILE"
    sed -i '/omarchy-workspace-bg-daemon/d' "$AUTOSTART_FILE"
    success "Cleaned autostart.conf"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                 Uninstall Complete!                        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Notes:"
echo "  - Your workspace wallpaper configs are preserved at:"
echo "    ${BLUE}~/.config/omarchy/workspace-backgrounds/${NC}"
echo ""
echo "  - Backups are preserved at:"
echo "    ${BLUE}~/.config/omarchy/backups/${NC}"
echo ""
echo "  - Restart Hyprland to fully apply changes"
echo ""
