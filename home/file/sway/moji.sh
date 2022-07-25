#! /usr/bin/env nix-shell
#! nix-shell -i bash -p rofimoji

# Determine which output is currently active (where the mouse pointer is). 🤔
MONITOR_ID=XWAYLAND$(swaymsg -t get_outputs | jq '[.[].focused] | index(true)')

# Let's pick our emojis! 🎉
rofimoji --action type --skin-tone light \
    --selector-args="-font 'Hack 12' -monitor ${MONITOR_ID}"
