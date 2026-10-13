#!/bin/sh
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/1000/hypr 2>/dev/null | head -n 1)
    export HYPRLAND_INSTANCE_SIGNATURE
fi
export QS_ICON_THEME="WhiteSur"
exec /run/current-system/sw/bin/serpantinumd start
