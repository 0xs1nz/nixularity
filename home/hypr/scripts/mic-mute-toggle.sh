#!/usr/bin/env bash

SOUNDS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/sounds"

wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle || exit 1

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
    sound="$SOUNDS_DIR/mic-mute.wav"
else
    sound="$SOUNDS_DIR/mic-unmute.wav"
fi

# Play the sound when the optional audio file is available.
if [[ -f "$sound" ]] && command -v pw-play >/dev/null 2>&1; then
    pw-play "$sound" >/dev/null 2>&1 &
fi

# Based on the original mic toggle script:
# https://www.reddit.com/r/linux_gaming/comments/1pj0o15/comment/o9bcx23/
