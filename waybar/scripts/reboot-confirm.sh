#!/bin/bash

# Simple confirmation dialog for reboot using wofi
echo -e "Yes\nNo" | wofi --dmenu --prompt "Confirm Reboot?" | grep -q "Yes" && systemctl reboot