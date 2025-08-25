#!/bin/bash
BASE=0xbf400000
DBELL=$((BASE + 0x100C))
while true; do
    VAL=$(sudo busybox devmem $DBELL 32)
    echo "$(date +%s) $VAL"
    sleep 0.1
done
