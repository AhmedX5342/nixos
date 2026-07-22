#!/usr/bin/env bash
current=$(setxkbmap -query | grep layout | awk '{print $2}')
if [ "$current" = "us" ]; then
    setxkbmap -layout ara -option caps:hyper
    xmodmap ~/.Xmodmap
else
    setxkbmap -layout us -option caps:hyper
    xmodmap ~/.Xmodmap
fi
xmodmap ~/.Xmodmap
