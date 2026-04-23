#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo."
    exit 1
fi

echo "Installing dependencies..."
apt update
xargs -a packages.txt apt install -y

REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
CONFIG_DIR="$USER_HOME/.config/labwc"

sudo -u "$REAL_USER" mkdir -p "$CONFIG_DIR"

if [ -f "wslk_prefs.reg" ]; then
    echo "Applying Wine registry fixes..."
    sudo -u "$REAL_USER" WINEPREFIX="$USER_HOME/.wine" wine regedit /s wslk_prefs.reg
else
    echo "Warning: wslk_prefs.reg not found. Skipping."
fi

if [ -f "rc.xml" ]; then
    echo "Configuring labwc..."
    cp rc.xml "$CONFIG_DIR/rc.xml"
    chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/rc.xml"
fi

# Deploy autostart from source file instead of heredoc
if [ -f "labwc_autostart" ]; then
    echo "Deploying autostart..."
    cp labwc_autostart "$CONFIG_DIR/autostart"
    chmod +x "$CONFIG_DIR/autostart"
    chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/autostart"
else
    echo "Warning: labwc_autostart not found. Skipping autostart deploy."
fi

echo "WSLK setup complete. Launch with: labwc"