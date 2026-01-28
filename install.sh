#!/bin/bash

# Omarchy Workspace Backgrounds Installer

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing Omarchy Workspace Backgrounds...${NC}"

# 1. Check Dependencies
echo "Checking dependencies..."
DEPS=(swww socat jq gum fzf chafa)
MISSING=()

for dep in "${DEPS[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        MISSING+=("$dep")
    fi
done

if [ ${#MISSING[@]} -ne 0 ]; then
    echo -e "${RED}Error: Missing dependencies: ${MISSING[*]}${NC}"
    echo "Please install them using your package manager."
    echo "Example: yay -S swww socat jq gum fzf chafa"
    exit 1
fi
echo "All dependencies found."

# 2. Install Scripts
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

echo "Installing scripts to $INSTALL_DIR..."
cp bin/omarchy-workspace-bg-daemon "$INSTALL_DIR/"
cp bin/omarchy-workspace-bg-config "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/omarchy-workspace-bg-daemon"
chmod +x "$INSTALL_DIR/omarchy-workspace-bg-config"

# Create shortcut 'wallpaper'
ln -sf "$INSTALL_DIR/omarchy-workspace-bg-config" "$INSTALL_DIR/wallpaper"
echo "Created alias 'wallpaper' -> 'omarchy-workspace-bg-config'"

# 3. Setup Config Directory
CONFIG_DIR="$HOME/.config/omarchy/workspace-bg"
CONFIG_FILE="$CONFIG_DIR/config.conf"

if [ ! -d "$CONFIG_DIR" ]; then
    echo "Creating config directory at $CONFIG_DIR..."
    mkdir -p "$CONFIG_DIR"
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating empty config file..."
    touch "$CONFIG_FILE"
fi

# 4. Setup Autostart
AUTOSTART_FILE="$HOME/.config/hypr/autostart.conf"
DAEMON_CMD="exec-once = $INSTALL_DIR/omarchy-workspace-bg-daemon"

if [ -f "$AUTOSTART_FILE" ]; then
    if grep -q "omarchy-workspace-bg-daemon" "$AUTOSTART_FILE"; then
        echo "Autostart entry already exists."
    else
        echo "Adding daemon to Hyprland autostart ($AUTOSTART_FILE)..."
        # Check if we should ask or just do it. Let's ask using gum since it's a dependency.
        if gum confirm "Add to Hyprland autostart?"; then
             # Remove old script reference if it exists (from previous manual setup)
             sed -i '\|omarchy/scripts/workspace-bg.sh|d' "$AUTOSTART_FILE"

             echo "" >> "$AUTOSTART_FILE"
             echo "# Omarchy Workspace Backgrounds" >> "$AUTOSTART_FILE"
             echo "$DAEMON_CMD" >> "$AUTOSTART_FILE"
             echo "Added."
        else
            echo "Skipping autostart configuration."
        fi
    fi
else
    echo -e "${RED}Warning: $AUTOSTART_FILE not found. Please add '$DAEMON_CMD' to your Hyprland config manually.${NC}"
fi

echo -e "${GREEN}Installation Complete!${NC}"
echo "Run 'wallpaper' to set up your wallpapers."
