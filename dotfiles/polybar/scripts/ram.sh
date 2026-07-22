#!/usr/bin/env bash
used=$(free | awk '/Mem:/ { printf("%.0f", $3/$2 * 100) }')
if [ "$used" -ge 90 ]; then
    echo "%{F#E06C75}${used}%%{F-}"
else
    echo "${used}%"
fi
