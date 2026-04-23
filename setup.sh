#!/bin/bash

# Ensure the script is run with sudo for the installation part
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo to install packages."
  exit
fi

# 1. Update and Install Labwc, Wine, and Foot
echo "Updating package lists and installing dependencies..."
apt update
apt install -y labwc foot wine

# Switch back to the actual user for file creation
# This ensures config files aren't owned by root
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
CONFIG_DIR="$USER_HOME/.config/labwc"

echo "Setting up configuration for user: $REAL_USER"

# 2. Create the configuration directory
sudo -u "$REAL_USER" mkdir -p "$CONFIG_DIR"

# 3. Create the rc.xml configuration file
echo "Writing rc.xml..."
sudo -u "$REAL_USER" tee "$CONFIG_DIR/rc.xml" > /dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<labwc_config>
  <core>
    <decoration>server</decoration>
    <gap>0</gap>
  </core>
  <keyboard>
    <default />
    <keybind key="W-Return">
      <action name="Execute" command="foot" />
    </keybind>
    <keybind key="W-Shift-q">
      <action name="Exit" />
    </keybind>
  </keyboard>
  <windowRules>
    <windowRule identifier="wine*" serverDecoration="yes" />
  </windowRules>
</labwc_config>
EOF

# 4. Create the autostart script
echo "Creating autostart script..."
sudo -u "$REAL_USER" tee "$CONFIG_DIR/autostart" > /dev/null <<EOF
#!/bin/bash
# Start the terminal in the background
foot &

# Optional: Uncomment the line below to launch your Wine shell automatically
# env -u DISPLAY WINEWAYLAND=1 wine explorer /desktop=shell,1280x800 &
EOF

# 5. Make the autostart script executable
chmod +x "$CONFIG_DIR/autostart"
chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/autostart"

echo "Installation and configuration complete. You can now start labwc by typing 'labwc'."