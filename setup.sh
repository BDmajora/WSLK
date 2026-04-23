#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo."
    exit 1
fi

echo "Installing dependencies..."
apt update
apt install -y wlr-randr sed swaybg wine

REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
CONFIG_DIR="$USER_HOME/.config/labwc"

sudo -u "$REAL_USER" mkdir -p "$CONFIG_DIR"

# Stage Registry
if [ -f "wslk_prefs.reg" ]; then
    cp wslk_prefs.reg "$USER_HOME/.wslk_prefs.reg"
    chown "$REAL_USER:$REAL_USER" "$USER_HOME/.wslk_prefs.reg"
fi

# Deploy rc.xml Template (No math here!)
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

echo "WSLK setup complete. Launch with: labwc"