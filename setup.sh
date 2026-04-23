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
fi

if [ -f "rc.xml" ]; then
    echo "Configuring labwc with precision coordinates..."
    
    # Detect output and resolution
    OUTPUT=$(wlr-randr 2>/dev/null | awk '/^[A-Za-z]/ {name=$1} /preferred, current/ {print name; exit}')
    RES=$(wlr-randr 2>/dev/null | awk '/preferred, current/ {print $1; exit}')
    
    [ -z "$OUTPUT" ] && OUTPUT="Virtual-1"
    [ -z "$RES" ] && RES="1280x800"

    # Precise Math: Wine taskbar is 28px. 
    # Height (800) - 28 = 772. This closes the gap seen in image_0b7c3b.png
    HEIGHT=$(echo "$RES" | cut -dx -f2)
    TASKBAR_Y=$((HEIGHT - 28))

    sed -e "s/__OUTPUT__/${OUTPUT}/g" \
        -e "s/__TASKBAR_Y__/${TASKBAR_Y}/g" \
        rc.xml > "$CONFIG_DIR/rc.xml"
        
    chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/rc.xml"
fi

if [ -f "labwc_autostart" ]; then
    echo "Deploying autostart..."
    cp labwc_autostart "$CONFIG_DIR/autostart"
    chmod +x "$CONFIG_DIR/autostart"
    chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/autostart"
fi

echo "WSLK setup complete. Launch with: labwc"