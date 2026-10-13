#!/usr/bin/env bash

SHADER="$HOME/.config/hypr/shaders/glossy_plastic.frag"
CURRENT=$(hyprctl getoption decoration:screen_shader -j | grep -o '"str": *"[^"]*"' | cut -d'"' -f4)

if [ "$CURRENT" = "$SHADER" ]; then
    hyprctl keyword decoration:screen_shader "[[EMPTY]]"
    notify-send "Shader" "Glossy plastic OFF" 2>/dev/null
else
    hyprctl keyword decoration:screen_shader "$SHADER"
    notify-send "Shader" "Glossy plastic ON" 2>/dev/null
fi
