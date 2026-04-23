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
    echo "Staging registry file..."
    cp wslk_prefs.reg "$USER_HOME/.wslk_prefs.reg"
    chown "$REAL_USER:$REAL_USER" "$USER_HOME/.wslk_prefs.reg"
else
    echo "Warning: wslk_prefs.reg not found. Skipping."
fi

if [ -f "rc.xml" ]; then
    echo "Configuring labwc..."
    # Detect output name at install time and inject into rc.xml
    OUTPUT=$(wlr-randr 2>/dev/null | awk '/^[A-Za-z]/ {name=$1} /preferred, current/ {print name; exit}')
    [ -z "$OUTPUT" ] && OUTPUT="Virtual-1"
    sed "s/__OUTPUT__/${OUTPUT}/g" rc.xml > "$CONFIG_DIR/rc.xml"
    chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/rc.xml"
fi

if [ -f "labwc_autostart" ]; then
    echo "Deploying autostart..."
    cp labwc_autostart "$CONFIG_DIR/autostart"
    chmod +x "$CONFIG_DIR/autostart"
    chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/autostart"
else
    echo "Warning: labwc_autostart not found. Skipping."
fi

echo "WSLK setup complete. Launch with: labwc"