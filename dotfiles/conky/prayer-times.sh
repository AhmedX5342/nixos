#!/bin/bash

# Configuration - Using coordinates for Cairo
LATITUDE="30.0444"
LONGITUDE="31.2357"
METHOD=5  # Egyptian General Authority of Survey

# Cache file
CACHE_FILE="$HOME/.cache/prayer_times.json"
CACHE_TIME=3600  # Cache for 1 hour

# Create cache directory if it doesn't exist
mkdir -p "$HOME/.cache"

# Check if cache is still valid
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [ $CACHE_AGE -lt $CACHE_TIME ] && [ -s "$CACHE_FILE" ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Fetch new data - IMPORTANT: -L flag follows redirects
RESPONSE=$(curl -sL --connect-timeout 10 --max-time 15 "http://api.aladhan.com/v1/timings?latitude=$LATITUDE&longitude=$LONGITUDE&method=$METHOD")

# Check if curl succeeded
if [ $? -eq 0 ] && [ ! -z "$RESPONSE" ] && echo "$RESPONSE" | grep -q '"code":200'; then
    echo "$RESPONSE" > "$CACHE_FILE"
    echo "$RESPONSE"
else
    # If fetch fails, use cache if available
    if [ -f "$CACHE_FILE" ] && [ -s "$CACHE_FILE" ]; then
        cat "$CACHE_FILE"
    fi
fi
