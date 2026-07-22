#!/usr/bin/env bash

PROJECT="$HOME/work/audaxa/qms-harmony"

# Save the window ID of the launching terminal so we can close it at the end
LAUNCH_WIN=$(xdotool getactivewindow)

# ── Workspace 1: Regular Brave ────────────────────────────────────────────────
brave &
sleep 1.5

# ── Workspace 2: VS Code ──────────────────────────────────────────────────────
code "$PROJECT" &
sleep 1

# ── Workspace 3: Two terminals side by side ───────────────────────────────────
i3-msg "workspace 4"
sleep 0.4

# Terminal 1: just cd into project
gnome-terminal --working-directory="$PROJECT" &
sleep 1

# Split horizontally for terminal 2
i3-msg "split h"
sleep 0.2

# Terminal 2: cd into project and run npm run dev
gnome-terminal --working-directory="$PROJECT" -- bash -c "exec bash" &
sleep 1

# Type 'npm run dev' and press Enter into the focused terminal
xdotool type --clearmodifiers "npm run dev"
xdotool key Return

# ── Workspace 4: Brave incognito ──────────────────────────────────────────────
sleep 1

# Get existing Brave window IDs before opening incognito
BRAVE_BEFORE=$(xdotool search --class "Brave" 2>/dev/null | tr '\n' ' ')

brave --incognito "http://localhost:8080/app" &
sleep 2

# Find the newly opened Brave window (the one that wasn't there before)
BRAVE_AFTER=$(xdotool search --class "Brave" 2>/dev/null)
for WID in $BRAVE_AFTER; do
    if ! echo "$BRAVE_BEFORE" | grep -qw "$WID"; then
        INCOGNITO_WIN=$WID
        break
    fi
done

# Move only the incognito window to workspace 4
if [ -n "$INCOGNITO_WIN" ]; then
    i3-msg "[id=$INCOGNITO_WIN] move to workspace 3; workspace 3"
else
    # Fallback
    i3-msg "workspace 3"
fi

# ── Close the launching terminal window ───────────────────────────────────────
sleep 0.3
xdotool windowclose "$LAUNCH_WIN"
