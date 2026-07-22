#!/usr/bin/env bash
## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Power Menu with Prayer Times
#
## Available Styles
#
## style-1   style-2   style-3   style-4   style-5

# Current Theme
dir="$HOME/.config/rofi/powermenu"
theme='style-1'

# CMDs
uptime=`uptime -p | sed -e 's/up //g'`
host=`hostname`

# Get prayer times
FAJR="N/A"
SUNRISE="N/A"
DHUHR="N/A"
ASR="N/A"
MAGHRIB="N/A"
ISHA="N/A"

if [ -f "$HOME/.config/rofi/prayer-times/get-prayer-times.sh" ]; then
    eval $(~/.config/rofi/prayer-times/get-prayer-times.sh 2>/dev/null)
fi

# Function to convert 12h time to minutes for comparison
time_to_mins() {
    local time=$1
    # Extract hour, minute, and AM/PM
    local hour=$(echo "$time" | grep -oP '^\d+')
    local min=$(echo "$time" | grep -oP ':\d+' | tr -d ':')
    local period=$(echo "$time" | grep -oP '[AP]M$')
    
    # Convert to 24h format
    if [ "$period" = "PM" ] && [ "$hour" != "12" ]; then
        hour=$((hour + 12))
    elif [ "$period" = "AM" ] && [ "$hour" = "12" ]; then
        hour=0
    fi
    
    echo $((hour * 60 + min))
}

# Get current time in minutes
CURRENT_MINS=$(($(date +%H) * 60 + $(date +%M)))

# Find next prayer
NEXT_PRAYER=""
if [ "$FAJR" != "N/A" ]; then
    FAJR_MINS=$(time_to_mins "$FAJR")
    DHUHR_MINS=$(time_to_mins "$DHUHR")
    ASR_MINS=$(time_to_mins "$ASR")
    MAGHRIB_MINS=$(time_to_mins "$MAGHRIB")
    ISHA_MINS=$(time_to_mins "$ISHA")
    
    if [ $CURRENT_MINS -lt $FAJR_MINS ]; then
        NEXT_PRAYER="Next: Fajr at $FAJR"
    elif [ $CURRENT_MINS -lt $DHUHR_MINS ]; then
        NEXT_PRAYER="Next: Dhuhr at $DHUHR"
    elif [ $CURRENT_MINS -lt $ASR_MINS ]; then
        NEXT_PRAYER="Next: Asr at $ASR"
    elif [ $CURRENT_MINS -lt $MAGHRIB_MINS ]; then
        NEXT_PRAYER="Next: Maghrib at $MAGHRIB"
    elif [ $CURRENT_MINS -lt $ISHA_MINS ]; then
        NEXT_PRAYER="Next: Isha at $ISHA"
    else
        NEXT_PRAYER="Next: Fajr at $FAJR (tomorrow)"
    fi
fi

# Combine uptime and next prayer
if [ ! -z "$NEXT_PRAYER" ]; then
    MESG="Uptime: $uptime\n$NEXT_PRAYER"
else
    MESG="Uptime: $uptime"
fi

# Options
shutdown=' Shutdown'
reboot=' Reboot'
lock=' Lock'
suspend=' Suspend'
logout=' Logout'
prayer=' Prayer Times'
yes=' Yes'
no=' No'

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "$host" \
		-mesg "$(echo -e "$MESG")" \
		-theme ${dir}/${theme}.rasi
}

# Confirmation CMD
confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 250px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Confirmation' \
		-mesg 'Are you Sure?' \
		-theme ${dir}/${theme}.rasi
}

# Prayer times menu
prayer_menu() {
	divider="---------"
	back=" Back"
	
	fajr="󰖨 Fajr       $FAJR"
	sunrise="󰖙 Sunrise    $SUNRISE"
	dhuhr="󰖚 Dhuhr      $DHUHR"
	asr="󰖛 Asr        $ASR"
	maghrib="󰖜 Maghrib    $MAGHRIB"
	isha="󰖔 Isha       $ISHA"
	
	chosen="$(echo -e "$fajr\n$sunrise\n$dhuhr\n$asr\n$maghrib\n$isha\n$divider\n$back" | rofi -dmenu -p "Prayer Times" -lines 9 -theme ${dir}/${theme}.rasi)"
	
	case ${chosen} in
		$back)
			run_rofi
			;;
		""|"$divider")
			;;
		*)
			# Copy time to clipboard
			TIME=$(echo "$chosen" | grep -oP '\d+:\d+ [AP]M')
			echo "$TIME" | xclip -selection clipboard 2>/dev/null
			notify-send "Prayer Time" "Copied: $TIME" -t 2000
			prayer_menu
			;;
	esac
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown\n$prayer" | rofi_cmd
}

# Execute Command
run_cmd() {
	selected="$(confirm_exit)"
	if [[ "$selected" == "$yes" ]]; then
		if [[ $1 == '--shutdown' ]]; then
			systemctl poweroff
		elif [[ $1 == '--reboot' ]]; then
			systemctl reboot
		elif [[ $1 == '--suspend' ]]; then
			mpc -q pause
			amixer set Master mute
			systemctl suspend
		elif [[ $1 == '--logout' ]]; then
			if [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
				openbox --exit
			elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
				bspc quit
			elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
				i3-msg exit
			elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
				qdbus org.kde.ksmserver /KSMServer logout 0 0 0
			fi
		fi
	else
		exit 0
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
		run_cmd --shutdown
        ;;
    $reboot)
		run_cmd --reboot
        ;;
    $lock)
		if [[ -x '/usr/local/bin/betterlockscreen' ]]; then
			betterlockscreen -l
		elif [[ -x '/usr/bin/i3lock' ]]; then
			i3lock
		fi
        ;;
    $suspend)
		run_cmd --suspend
        ;;
    $logout)
		run_cmd --logout
        ;;
    $prayer)
		prayer_menu
        ;;
esac
