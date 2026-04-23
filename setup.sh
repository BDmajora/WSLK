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

echo "Creating autostart..."
sudo -u "$REAL_USER" tee "$CONFIG_DIR/autostart" > /dev/null <<'EOF'
#!/bin/bash

# Set solid background color (no wallpaper needed)
swaybg -c "#366ea5" &

# Wait for Wayland compositor to be fully ready
sleep 1

# Get resolution robustly
RES=$(wlr-randr 2>/dev/null | awk '/[0-9]+x[0-9]+/ && /current/ {print $1; exit}')
[ -z "$RES" ] && RES=$(wlr-randr 2>/dev/null | awk 'match($0, /[0-9]+x[0-9]+/) {print substr($0, RSTART, RLENGTH); exit}')
[ -z "$RES" ] && RES="1280x800"

echo "Detected resolution: $RES" >> /tmp/wslk_autostart.log

# Launch Wine shell
WINEPREFIX="$HOME/.wine" \
WINEWAYLAND=1 \
DISPLAY="" \
wine explorer /desktop=shell,"$RES" >> /tmp/wslk_autostart.log 2>&1 &
EOF

chmod +x "$CONFIG_DIR/autostart"
chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/autostart"

echo "WSLK setup complete. Launch with: labwc"