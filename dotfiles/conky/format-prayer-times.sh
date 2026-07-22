#!/bin/bash

# Get prayer times
PRAYER_DATA=$(~/.config/conky/prayer-times.sh 2>&1)

# Check if we got data
if [ -z "$PRAYER_DATA" ]; then
    echo "No response from API"
    exit 1
fi

# Simple grep-based parsing (no jq needed)
FAJR=$(echo "$PRAYER_DATA" | grep -oP '"Fajr":"\K[^"]+' | head -1)
SUNRISE=$(echo "$PRAYER_DATA" | grep -oP '"Sunrise":"\K[^"]+' | head -1)
DHUHR=$(echo "$PRAYER_DATA" | grep -oP '"Dhuhr":"\K[^"]+' | head -1)
ASR=$(echo "$PRAYER_DATA" | grep -oP '"Asr":"\K[^"]+' | head -1)
MAGHRIB=$(echo "$PRAYER_DATA" | grep -oP '"Maghrib":"\K[^"]+' | head -1)
ISHA=$(echo "$PRAYER_DATA" | grep -oP '"Isha":"\K[^"]+' | head -1)

# Check if we got times
if [ -z "$FAJR" ]; then
    echo "Error parsing times"
    echo "Debug: $PRAYER_DATA" | head -c 100
    exit 1
fi

# Format output
cat << EOF
  Fajr    : $FAJR
  Sunrise : $SUNRISE
  Dhuhr   : $DHUHR
  Asr     : $ASR
  Maghrib : $MAGHRIB
  Isha    : $ISHA
EOF
