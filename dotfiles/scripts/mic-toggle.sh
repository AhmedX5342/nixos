#!/usr/bin/env bash

case "$1" in
    toggle)
        # Use pactl's built-in toggle function
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        # Then show the NEW state
        MUTED=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')
        if [ "$MUTED" = "yes" ]; then
            echo "󰍭 "
        else
            echo "󰍬 "
        fi
        ;;
    status)
        MUTED=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')
        if [ "$MUTED" = "yes" ]; then
            echo "󰍭 "
        else
            echo "󰍬 "
        fi
        ;;
esac
