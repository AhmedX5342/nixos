#!/usr/bin/env bash

pkill polybar

if xrandr | grep -q "^HDMI-1-0 connected"; then
    # External monitor ONLY (preferred mode)
    xrandr \
      --output HDMI-1-0 --auto --primary \
      --output eDP-1 --off
else
    # Laptop screen ONLY
    xrandr \
      --output eDP-1 --auto --primary \
      --output HDMI-1-0 --off
fi

sleep 1
#hdmi-1-0 is my second monitor while eDP-1 is my laptop's screen
#feh --bg-fill ~/Pictures/january\ 2026/the-witcher-3-wild-hunt-skellige-wallpaper-7efe6c4db25b6c93f0869586026c38a6.jpg
#feh --bg-fill ~/Pictures/january\ 2026/a_iceberg_in_the_water_with_mountains_in_the_background.jpg
#feh --bg-fill ~/Pictures/feb\ 2026/kali.png
#feh --bg-fill ~/Pictures/feb\ 2026/mountains.jpg
#feh --bg-fill ~/Pictures/january\ 2026/b2n28xda32651.jpg
feh --bg-fill ~/Pictures/march\ 2026/mountains2.jpg
#feh --bg-fill ~/Pictures/april\ 2026/dark2.jpg
picom --config ~/.config/picom/picom.conf
# set default audio device
pactl set-default-sink alsa_output.usb-Razer_Razer_Kraken_Ultimate_00000000-00.analog-stereo
pactl set-default-source alsa_input.usb-Razer_Razer_Kraken_Ultimate_00000000-00.analog-stereo
~/.config/polybar/launch.sh &
