#!/usr/bin/env bash
## WiFi Menu with Power Menu Styling
# Theme Configuration
dir="$HOME/.config/rofi/wifi"
theme='style-1'
# Get WiFi info
FIELDS=SSID,SECURITY
LIST=$(nmcli --fields "$FIELDS" device wifi list | sed '/^--/d')
KNOWNCON=$(nmcli connection show)
CONSTATE=$(nmcli -fields WIFI g)
CURRSSID=$(LANGUAGE=C nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')
# WiFi status message
if [[ ! -z $CURRSSID ]]; then
    wifi_status="Connected: $CURRSSID"
else
    wifi_status="Not Connected"
fi
# Toggle option
if [[ "$CONSTATE" =~ "enabled" ]]; then
    TOGGLE="󰖪 Toggle Off"
else
    TOGGLE="󰖩 Toggle On"
fi
# Options
manual="󰣉 Manual Entry"
divider="---------"
# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "Wi-Fi" \
        -mesg "$wifi_status" \
        -theme ${dir}/${theme}.rasi
}
# Show menu
if [[ "$CONSTATE" =~ "enabled" ]]; then
    CHENTRY=$(echo -e "$TOGGLE\n$manual\n$divider\n$LIST" | rofi_cmd)
else
    CHENTRY=$(echo -e "$TOGGLE" | rofi_cmd)
fi
CHSSID=$(echo "$CHENTRY" | sed 's/\s\{2,\}/|/g' | awk -F "|" '{print $1}')
# Handle selection
case "$CHENTRY" in
    "$manual")
        MSSID=$(echo "" | rofi -dmenu -p "SSID,password" -theme ${dir}/${theme}.rasi)
        MPASS=$(echo "$MSSID" | awk -F "," '{print $2}')
        MSSID=$(echo "$MSSID" | awk -F "," '{print $1}')
        
        if [ "$MPASS" = "" ]; then
            nmcli dev wifi con "$MSSID"
        else
            nmcli dev wifi con "$MSSID" password "$MPASS"
        fi
        ;;
    "$TOGGLE")
        if [[ "$CONSTATE" =~ "enabled" ]]; then
            nmcli radio wifi off
        else
            nmcli radio wifi on
        fi
        ;;
    ""|"$divider")
        exit 0
        ;;
        *)
        # Extract SSID - handle both connected (*) and unconnected networks
        CHSSID=$(echo "$CHENTRY" | sed 's/^*\s*//' | sed 's/\s\{2,\}.*//')
        
        # Check if this is a known connection (more flexible matching)
        if nmcli -t -f NAME con show | grep -Fxq "$CHSSID"; then
            nmcli con up "$CHSSID"
        else
            # Check if password is needed
            if [[ "$CHENTRY" =~ "WPA" ]] || [[ "$CHENTRY" =~ "WEP" ]]; then
                # Use default rofi theme to ensure input field appears
                WIFIPASS=$(rofi -dmenu -password -p "Password for $CHSSID")
                
                if [ -n "$WIFIPASS" ]; then
                    nmcli dev wifi con "$CHSSID" password "$WIFIPASS"
                fi
            else
                # Open network, no password needed
                nmcli dev wifi con "$CHSSID"
            fi
        fi
        ;;
esac
