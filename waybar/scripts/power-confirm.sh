#!/bin/bash

# Simple confirmation dialog for power off using wofi
echo -e "Yes\nNo" | wofi --dmenu --prompt "Confirm Power Off?" | grep -q "Yes" && systemctl poweroff