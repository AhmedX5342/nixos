#!/usr/bin/env bash
## Prayer Times Menu with Power Menu Styling

# Theme Configuration
dir="$HOME/.config/rofi/powermenu"
theme='style-1'

# Get prayer times data
get_prayer_times() {
    LATITUDE="30.0444"
    LONGITUDE="31.2357"
    METHOD=5
    
    CACHE_FILE="$HOME/.cache/prayer_times.json"
    CACHE_TIME=3600
    
    mkdir -p "$HOME/.cache"
    
    # Check cache
    if [ -f "$CACHE_FILE" ]; then
        CACHE_AGE=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
        if [ $CACHE_AGE -lt $CACHE_TIME ] && [ -s "$CACHE_FILE" ]; then
            cat "$CACHE_FILE"
            return
        fi
    fi
    
    # Fetch new data
    RESPONSE=$(curl -sL --connect-timeout 10 --max-time 15 "http://api.aladhan.com/v1/timings?latitude=$LATITUDE&longitude=$LONGITUDE&method=$METHOD")
    
    if [ $? -eq 0 ] && [ ! -z "$RESPONSE" ] && echo "$RESPONSE" | grep -q '"code":200'; then
        echo "$RESPONSE" > "$CACHE_FILE"
        echo "$RESPONSE"
    elif [ -f "$CACHE_FILE" ] && [ -s "$CACHE_FILE" ]; then
        cat "$CACHE_FILE"
    fi
}

# Parse prayer times
PRAYER_DATA=$(get_prayer_times)

if [ -z "$PRAYER_DATA" ]; then
    notify-send "Prayer Times" "Unable to fetch prayer times" -u critical
    exit 1
fi

# Extract times
FAJR=$(echo "$PRAYER_DATA" | grep -oP '"Fajr":"\K[^"]+' | head -1)
SUNRISE=$(echo "$PRAYER_DATA" | grep -oP '"Sunrise":"\K[^"]+' | head -1)
DHUHR=$(echo "$PRAYER_DATA" | grep -oP '"Dhuhr":"\K[^"]+' | head -1)
ASR=$(echo "$PRAYER_DATA" | grep -oP '"Asr":"\K[^"]+' | head -1)
MAGHRIB=$(echo "$PRAYER_DATA" | grep -oP '"Maghrib":"\K[^"]+' | head -1)
ISHA=$(echo "$PRAYER_DATA" | grep -oP '"Isha":"\K[^"]+' | head -1)

# Extract date info
HIJRI_DATE=$(echo "$PRAYER_DATA" | grep -oP '"readable":"\K[^"]+' | head -1)
GREGORIAN_DATE=$(date "+%A, %B %d, %Y")

# Get current time for highlighting
CURRENT_TIME=$(date +%H:%M)

# Status message
STATUS="$GREGORIAN_DATE"

# Options
divider="---------"
refresh="󰑐 Refresh"
fajr_opt="󰖨 Fajr       $FAJR"
sunrise_opt="󰖙 Sunrise    $SUNRISE"
dhuhr_opt="󰖚 Dhuhr      $DHUHR"
asr_opt="󰖛 Asr        $ASR"
maghrib_opt="󰖜 Maghrib    $MAGHRIB"
isha_opt="󰖔 Isha       $ISHA"

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "Prayer Times" \
        -mesg "$STATUS" \
        -lines 9 \
        -theme ${dir}/${theme}.rasi
}

# Show menu
chosen="$(echo -e "$fajr_opt\n$sunrise_opt\n$dhuhr_opt\n$asr_opt\n$maghrib_opt\n$isha_opt\n$divider\n$refresh" | rofi_cmd)"

# Handle selection
case "$chosen" in
    "$refresh")
        rm -f "$HOME/.cache/prayer_times.json"
        exec "$0"
        ;;
    ""|"$divider")
        exit 0
        ;;
    *)
        # Copy selected time to clipboard
        TIME=$(echo "$chosen" | awk '{print $NF}')
        echo "$TIME" | xclip -selection clipboard 2>/dev/null || echo "$TIME" | wl-copy 2>/dev/null
        notify-send "Prayer Time" "Copied: $TIME" -t 2000
        ;;
esac
