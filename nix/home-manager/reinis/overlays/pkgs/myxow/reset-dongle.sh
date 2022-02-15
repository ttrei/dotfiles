#!/usr/bin/env bash

# Reset Xbox wireless dongle by suspending and resuming the USB device

DEVICE_ID=$(dmesg | grep "XBOX ACC" | head -n1 | grep -P "usb.*?:" -o | cut -d":" -f1 | cut -d" " -f2)

if [[ -z "$DEVICE_ID" ]]; then
    echo "Xbox wireless dongle not found"
    exit 1
fi

DEVICE_PATH="/sys/bus/usb/devices/$DEVICE_ID"

# suspend
echo "0" > "$DEVICE_PATH/power/autosuspend_delay_ms"
echo "auto" > "$DEVICE_PATH/power/control"
sleep 0.1
# resume
echo "on" > "$DEVICE_PATH/power/control"
