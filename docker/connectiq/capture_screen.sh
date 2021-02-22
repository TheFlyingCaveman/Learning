#!/bin/sh

Xvfb :1 -screen 5 1024x768x8 &
pidof /usr/bin/Xvfb
DISPLAY=:1 connectiq >/dev/null &
sleep 10
DISPLAY=:1 xwd -root -silent | convert xwd:- png:/tmp/screenshot.png