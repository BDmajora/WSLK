#!/bin/bash

# Define configuration directory
CONFIG_DIR="$HOME/.config/labwc"

# Create the directory if it does not exist
echo "Creating configuration directory at $CONFIG_DIR..."
mkdir -p "$CONFIG_DIR"

# Create the rc.xml configuration file
echo "Writing rc.xml..."
cat <<EOF > "$CONFIG_DIR/rc.xml"
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

# Create the autostart script to launch the terminal on boot
echo "Creating autostart script..."
cat <<EOF > "$CONFIG_DIR/autostart"
#!/bin/bash
# Launch foot terminal in the background
foot &
EOF

# Make the autostart script executable
chmod +x "$CONFIG_DIR/autostart"

echo "Setup complete. You can now start labwc."