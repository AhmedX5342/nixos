#!/bin/bash

while true; do
    # Get current workspace
    CURRENT_WS=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name')
    
    # Count windows on current workspace (excluding conky and i3bar)
    WINDOW_COUNT=$(i3-msg -t get_tree | jq "[recurse(.nodes[]?) | select(.window_properties.class and .window_properties.class != \"Conky\" and .focused == true)] | length")
    
    # Get all windows on current workspace
    WINDOWS=$(i3-msg -t get_tree | jq -r '.. | select(.type? == "workspace" and .focused == true) | .. | select(.window? != null and .window_properties.class? != "Conky") | .window_properties.class' 2>/dev/null | wc -l)
    
    if [ "$WINDOWS" -eq 0 ]; then
        # Show conky if workspace is empty
        xdotool search --class "Conky" windowmap 2>/dev/null
    else
        # Hide conky if there are windows
        xdotool search --class "Conky" windowunmap 2>/dev/null
    fi
    
    sleep 1
done
