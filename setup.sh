#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo."
  exit
fi

# 1. Install dependencies
echo "Installing dependencies..."
apt update
# Ensure packages.txt includes: labwc wine psmisc wlr-randr
xargs -a packages.txt apt install -y

REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
CONFIG_DIR="$USER_HOME/.config/labwc"

# 2. Setup Directories
sudo -u "$REAL_USER" mkdir -p "$CONFIG_DIR"

# 3. Apply Registry Fixes (The Native Way)
if [ -f "wslk_prefs.reg" ]; then
    echo "Applying Wine registry fixes..."
    # Run as the real user to target their default Wine prefix
    sudo -u "$REAL_USER" wine regedit /s wslk_prefs.reg
else
    echo "Warning: wslk_prefs.reg not found. Skipping registry fix."
fi

# 4. Apply rc.xml
if [ -f "rc.xml" ]; then
    echo "Configuring labwc..."
    cp rc.xml "$CONFIG_DIR/rc.xml"
    chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/rc.xml"
fi

# 5. Create DYNAMIC Autostart
echo "Creating dynamic autostart script..."
sudo -u "$REAL_USER" tee "$CONFIG_DIR/autostart" > /dev/null <<'EOF'
#!/bin/bash

# Get the resolution of the first active monitor
RES=$(wlr-randr | grep -m 1 'current' | awk '{print $1}')

# Launch Wine Desktop scaled to the detected resolution
# No terminal spawn, just the native shell
if [ -n "$RES" ]; then
    env -u DISPLAY WINEWAYLAND=1 wine explorer /desktop=shell,"$RES" &
else
    env -u DISPLAY WINEWAYLAND=1 wine explorer /desktop=shell,1280x800 &
fi
EOF

# 6. Permissions
chmod +x "$CONFIG_DIR/autostart"
chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/autostart"

echo "WSLK setup complete. Registry applied. Launch with 'labwc'."