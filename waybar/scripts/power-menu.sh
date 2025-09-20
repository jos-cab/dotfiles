#!/bin/bash

# HACK: only use confirm
# Power menu using wofi
SELECTION=$(echo -e "Shutdown\nReboot\nSleep\nLogout" | wofi --dmenu --prompt "Power Menu")

case $SELECTION in
  "Shutdown")
    echo -e "Yes\nNo" | wofi --dmenu --prompt "Confirm Shutdown?" | grep -q "Yes" && systemctl poweroff
    ;;
  "Reboot")
    echo -e "Yes\nNo" | wofi --dmenu --prompt "Confirm Reboot?" | grep -q "Yes" && systemctl reboot
    ;;
  "Sleep")
    echo -e "Yes\nNo" | wofi --dmenu --prompt "Confirm Sleep?" | grep -q "Yes" && systemctl suspend
    ;;
  "Logout")
    echo -e "Yes\nNo" | wofi --dmenu --prompt "Confirm Logout?" | grep -q "Yes" && loginctl terminate-user $(whoami)
    ;;
esac