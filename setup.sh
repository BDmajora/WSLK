#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo."
    exit 1
fi

echo "Installing dependencies..."
apt update && apt install -y wlr-randr sed swaybg wine

REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
CONFIG_DIR="$USER_HOME/.config/labwc"

sudo -u "$REAL_USER" mkdir -p "$CONFIG_DIR"

# Deploy Registry
[ -f "wslk_prefs.reg" ] && cp wslk_prefs.reg "$USER_HOME/.wslk_prefs.reg"

# Deploy rc.xml Template (No math allowed here!)
if [ -f "rc.xml" ]; then
    cp rc.xml "$CONFIG_DIR/rc.xml"
    chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/rc.xml"
fi

# Deploy Autostart
if [ -f "labwc_autostart" ]; then
    cp labwc_autostart "$CONFIG_DIR/autostart"
    chmod +x "$CONFIG_DIR/autostart"
    chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/autostart"
fi

chown "$REAL_USER:$REAL_USER" "$USER_HOME/.wslk_prefs.reg"
echo "WSLK setup complete."