#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo."
    exit 1
fi

echo "Installing dependencies..."
apt update
# Ensure wlr-randr and sed are present for the autostart logic
apt install -y wlr-randr sed

REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
CONFIG_DIR="$USER_HOME/.config/labwc"

sudo -u "$REAL_USER" mkdir -p "$CONFIG_DIR"

# Stage Registry
if [ -f "wslk_prefs.reg" ]; then
    cp wslk_prefs.reg "$USER_HOME/.wslk_prefs.reg"
    chown "$REAL_USER:$REAL_USER" "$USER_HOME/.wslk_prefs.reg"
fi

# THE REAL NO-HARDCODE FIX: Just deploy the template
# We stop doing math here because sudo/setup environment doesn't know the resolution yet.
if [ -f "rc.xml" ]; then
    echo "Deploying rc.xml template..."
    cp rc.xml "$CONFIG_DIR/rc.xml"
    chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/rc.xml"
fi

# Deploy Autostart
if [ -f "labwc_autostart" ]; then
    echo "Deploying autostart script..."
    cp labwc_autostart "$CONFIG_DIR/autostart"
    chmod +x "$CONFIG_DIR/autostart"
    chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/autostart"
fi

echo "WSLK setup complete. Launch with: labwc"