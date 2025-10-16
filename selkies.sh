#!/usr/bin/env bash
set -eu

export LANG="de_DE.UTF-8"

XVFB_DISPLAY=":5"
XVFB_RESOLUTION="8192x8192x24"

# 1. Xvfb
if ! pgrep -x "Xvfb" > /dev/null; then
    echo "Start Xvfb on $XVFB_DISPLAY with resolution $XVFB_RESOLUTION..."
        /usr/bin/Xvfb $XVFB_DISPLAY -screen 0 15360x8640x24 -dpi 96 \
            +extension COMPOSITE \
            +extension DAMAGE    \
            +extension GLX       \
            +extension RANDR     \
            +extension RENDER    \
            +extension MIT-SHM   \
            +extension XFIXES    \
            +extension XTEST     \
            +extension XFIXES    \
            +iglx                \
            +render -nolisten tcp -ac -noreset -shmem &
    sleep 1
fi

echo "Start LXDE on $XVFB_DISPLAY..."
export DISPLAY=$XVFB_DISPLAY

setxkbmap de
startlxde &
sleep 3

echo "Start selkies..."
/usr/local/share/selkies/selkies-gstreamer/selkies-gstreamer-run \
    --addr=0.0.0.0 \
    --port=8080 \
    --enable_https=false \
    --basic_auth_user=user \
    --basic_auth_password=awesomepw \
    --encoder=x264enc \
    --enable_resize=true
