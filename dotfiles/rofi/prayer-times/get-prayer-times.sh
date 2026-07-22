#!/usr/bin/env bash

# Get prayer times data
PRAYER_DATA=$(~/.config/rofi/prayer-times/prayer-times.sh 2>&1)

if [ -z "$PRAYER_DATA" ] || ! echo "$PRAYER_DATA" | grep -q "Fajr"; then
    echo "FAJR='N/A'"
    echo "SUNRISE='N/A'"
    echo "DHUHR='N/A'"
    echo "ASR='N/A'"
    echo "MAGHRIB='N/A'"
    echo "ISHA='N/A'"
    exit 1
fi

# Function to convert 24h to 12h format
to_12h() {
    local time=$1
    if [ -z "$time" ]; then
        echo "N/A"
        return
    fi
    
    local hour=$(echo $time | cut -d: -f1)
    local min=$(echo $time | cut -d: -f2)
    
    # Remove leading zeros
    hour=$((10#$hour))
    
    if [ $hour -eq 0 ]; then
        echo "12:$min AM"
    elif [ $hour -lt 12 ]; then
        echo "$hour:$min AM"
    elif [ $hour -eq 12 ]; then
        echo "12:$min PM"
    else
        echo "$((hour - 12)):$min PM"
    fi
}

# Extract times
FAJR=$(echo "$PRAYER_DATA" | grep -oP '"Fajr":"\K[^"]+' | head -1)
SUNRISE=$(echo "$PRAYER_DATA" | grep -oP '"Sunrise":"\K[^"]+' | head -1)
DHUHR=$(echo "$PRAYER_DATA" | grep -oP '"Dhuhr":"\K[^"]+' | head -1)
ASR=$(echo "$PRAYER_DATA" | grep -oP '"Asr":"\K[^"]+' | head -1)
MAGHRIB=$(echo "$PRAYER_DATA" | grep -oP '"Maghrib":"\K[^"]+' | head -1)
ISHA=$(echo "$PRAYER_DATA" | grep -oP '"Isha":"\K[^"]+' | head -1)

# Convert to 12-hour format
FAJR_12=$(to_12h "$FAJR")
SUNRISE_12=$(to_12h "$SUNRISE")
DHUHR_12=$(to_12h "$DHUHR")
ASR_12=$(to_12h "$ASR")
MAGHRIB_12=$(to_12h "$MAGHRIB")
ISHA_12=$(to_12h "$ISHA")

# Export for use in power menu
echo "FAJR='$FAJR_12'"
echo "SUNRISE='$SUNRISE_12'"
echo "DHUHR='$DHUHR_12'"
echo "ASR='$ASR_12'"
echo "MAGHRIB='$MAGHRIB_12'"
echo "ISHA='$ISHA_12'"
