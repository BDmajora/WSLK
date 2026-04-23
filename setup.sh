#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo."
  exit
fi

# 1. Install dependencies
echo "Installing dependencies..."
apt update
xargs -a packages.txt apt install -y

REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
CONFIG_DIR="$USER_HOME/.config/labwc"

# 2. Setup Directories
sudo -u "$REAL_USER" mkdir -p "$CONFIG_DIR"

# 3. Apply rc.xml
if [ -f "rc.xml" ]; then
    cp rc.xml "$CONFIG_DIR/rc.xml"
    chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/rc.xml"
fi

# 4. Create DYNAMIC Autostart
echo "Creating dynamic autostart script..."
sudo -u "$REAL_USER" tee "$CONFIG_DIR/autostart" > /dev/null <<'EOF'
#!/bin/bash

# Get the resolution of the first active monitor (e.g., 1920x1080)
RES=$(wlr-randr | grep -m 1 'current' | awk '{print $1}')

# Launch Wine Desktop scaled to the detected resolution
if [ -n "$RES" ]; then
    env -u DISPLAY WINEWAYLAND=1 wine explorer /desktop=shell,"$RES" &
else
    # Fallback if detection fails
    env -u DISPLAY WINEWAYLAND=1 wine explorer /desktop=shell,1280x800 &
fi
EOF

# 5. Permissions
chmod +x "$CONFIG_DIR/autostart"
chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/autostart"

echo "WSLK setup complete. No terminal will spawn on boot."