#!/usr/bin/env bash
#             __ _       _     _            _              _   _
#  _ __ ___  / _(_)     | |__ | |_   _  ___| |_ ___   ___ | |_| |__
# | '__/ _ \| |_| |_____| '_ \| | | | |/ _ \ __/ _ \ / _ \| __| '_ \
# | | | (_) |  _| |_____| |_) | | |_| |  __/ || (_) | (_) | |_| | | |
# |_|  \___/|_| |_|     |_.__/|_|\__,_|\___|\__\___/ \___/ \__|_| |_|
#
# Author: Nick Clyde (clydedroid)
#
# A script that generates a rofi menu that uses bluetoothctl to
# connect to bluetooth devices and display status info.
#
# Inspired by networkmanager-dmenu (https://github.com/firecat53/networkmanager-dmenu)
# Thanks to x70b1 (https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts/system-bluetooth-bluetoothctl)
#
# Depends on:
#   Arch repositories: rofi, bluez-utils (contains bluetoothctl), bc
#!/usr/bin/env bash
## Bluetooth Menu with Power Menu Styling

# Theme Configuration
dir="$HOME/.config/rofi/bluetooth"
theme='style-1'

# Constants
divider="---------"
goback="󰁍 Back"

# Helper functions
power_on() {
    bluetoothctl show | grep -q "Powered: yes"
}

scan_on() {
    bluetoothctl show | grep -q "Discovering: yes"
}

device_connected() {
    bluetoothctl info "$1" | grep -q "Connected: yes"
}

device_paired() {
    bluetoothctl info "$1" | grep -q "Paired: yes"
}

device_trusted() {
    bluetoothctl info "$1" | grep -q "Trusted: yes"
}

# Get bluetooth status
get_status() {
    if power_on; then
        paired_devices_cmd="devices Paired"
        if (( $(echo "$(bluetoothctl version | cut -d ' ' -f 2) < 5.65" | bc -l) )); then
            paired_devices_cmd="paired-devices"
        fi
        
        mapfile -t paired_devices < <(bluetoothctl $paired_devices_cmd | grep Device | cut -d ' ' -f 2)
        connected_devices=""
        
        for device in "${paired_devices[@]}"; do
            if device_connected "$device"; then
                device_alias=$(bluetoothctl info "$device" | grep "Alias" | cut -d ' ' -f 2-)
                if [ -z "$connected_devices" ]; then
                    connected_devices="$device_alias"
                else
                    connected_devices="$connected_devices, $device_alias"
                fi
            fi
        done
        
        if [ -z "$connected_devices" ]; then
            echo "No devices connected"
        else
            echo "Connected: $connected_devices"
        fi
    else
        echo "Bluetooth: Off"
    fi
}

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "Bluetooth" \
        -mesg "$(get_status)" \
        -theme ${dir}/${theme}.rasi
}

# Device submenu
device_menu() {
    device=$1
    device_name=$(echo "$device" | cut -d ' ' -f 3-)
    mac=$(echo "$device" | cut -d ' ' -f 2)
    
    if device_connected "$mac"; then
        connected="󰂯 Connected"
    else
        connected="󰂲 Disconnected"
    fi
    
    if device_paired "$mac"; then
        paired="󰂱 Paired"
    else
        paired="󰂳 Unpaired"
    fi
    
    if device_trusted "$mac"; then
        trusted="󰗹 Trusted"
    else
        trusted="󰗺 Untrusted"
    fi
    
    options="$connected\n$paired\n$trusted\n$divider\n$goback"
    chosen="$(echo -e "$options" | rofi -dmenu -p "$device_name" -theme ${dir}/${theme}.rasi)"
    
    case "$chosen" in
        "$connected")
            if device_connected "$mac"; then
                bluetoothctl disconnect "$mac"
            else
                bluetoothctl connect "$mac"
            fi
            device_menu "$device"
            ;;
        "$paired")
            if device_paired "$mac"; then
                bluetoothctl remove "$mac"
            else
                bluetoothctl pair "$mac"
            fi
            device_menu "$device"
            ;;
        "$trusted")
            if device_trusted "$mac"; then
                bluetoothctl untrust "$mac"
            else
                bluetoothctl trust "$mac"
            fi
            device_menu "$device"
            ;;
        "$goback")
            show_menu
            ;;
    esac
}

# Main menu
show_menu() {
    if power_on; then
        power="󰂯 Power: On"
        devices=$(bluetoothctl devices | grep Device | cut -d ' ' -f 3-)
        
        if bluetoothctl show | grep -q "Discovering: yes"; then
            scan="󰑐 Scan: On"
        else
            scan="󰑐 Scan: Off"
        fi
        
        options="$power\n$scan\n$divider\n$devices"
    else
        power="󰂲 Power: Off"
        options="$power"
    fi
    
    chosen="$(echo -e "$options" | rofi_cmd)"
    
    case "$chosen" in
        ""|"$divider")
            exit 0
            ;;
        "$power")
            if power_on; then
                bluetoothctl power off
            else
                if rfkill list bluetooth | grep -q 'blocked: yes'; then
                    rfkill unblock bluetooth && sleep 3
                fi
                bluetoothctl power on
            fi
            show_menu
            ;;
        "$scan")
            if bluetoothctl show | grep -q "Discovering: yes"; then
                kill $(pgrep -f "bluetoothctl scan on") 2>/dev/null
                bluetoothctl scan off
            else
                bluetoothctl scan on &
            fi
            show_menu
            ;;
        *)
            device=$(bluetoothctl devices | grep "$chosen")
            if [[ $device ]]; then
                device_menu "$device"
            fi
            ;;
    esac
}

show_menu
