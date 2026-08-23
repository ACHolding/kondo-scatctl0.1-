#!/bin/bash

# Script Name: cattcp.sh
# Purpose: Automatically resets a macOS network interface after 40 days of
# system uptime, then checks periodically.

# Network interface (en0 is commonly Wi-Fi on modern Macs; verify with:
# networksetup -listallhardwareports)
INTERFACE="en0"

# Threshold in seconds (40 days = 3,456,000 seconds)
THRESHOLD=3456000

echo "================================================="
echo "CatTCP: macOS Marathon Uptime Network Guard"
echo "================================================="

while true; do
    # Get boot time and calculate uptime in seconds.
    BOOT_TIME=$(sysctl -n kern.boottime | awk -F'sec = ' '{print $2}' | awk -F',' '{print $1}')
    CURRENT_TIME=$(date +%s)
    UPTIME=$((CURRENT_TIME - BOOT_TIME))
    UPTIME_DAYS=$((UPTIME / 86400))

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Current Mac Uptime: ${UPTIME_DAYS} days (${UPTIME} seconds)"

    # Check if uptime has crossed the 40-day mark.
    if [ "$UPTIME" -ge "$THRESHOLD" ]; then
        echo "[WARNING] Uptime has passed 40 days! Recycling network interface..."

        sudo ifconfig "$INTERFACE" down
        sleep 2
        sudo ifconfig "$INTERFACE" up

        echo "[SUCCESS] Network interface $INTERFACE recycled."

        # Avoid repeatedly recycling the interface.
        sleep 86400
    else
        echo "[INFO] Below configured threshold. Next check in 12 hours."
        sleep 43200
    fi
done
