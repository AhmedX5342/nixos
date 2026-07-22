#!/usr/bin/env bash
used=$(top -bn1 | awk '/Cpu/ { printf("%.0f", 100 - $8) }')
if [ "$used" -ge 90 ]; then
    echo "%{F#E06C75}${used}%%{F-}"
else
    echo "${used}%"
fi
