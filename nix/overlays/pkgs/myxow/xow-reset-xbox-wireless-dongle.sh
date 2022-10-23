#!/usr/bin/env bash

# Reset Xbox wireless dongle by suspending and resuming the USB device

USB_PORT_ID=$(dmesg | grep 045e.*02fe | head -n1 | grep -P "usb.*?:" -o | cut -d":" -f1 | cut -d" " -f2)

if [[ -z "$USB_PORT_ID" ]]; then
    echo "Xbox wireless dongle not found"
    exit 1
fi

USB_PORT="/sys/bus/usb/devices/$USB_PORT_ID"

# suspend
echo "0" > "$USB_PORT/power/autosuspend_delay_ms"
echo "auto" > "$USB_PORT/power/control"
sleep 0.1
# resume
echo "on" > "$USB_PORT/power/control"
