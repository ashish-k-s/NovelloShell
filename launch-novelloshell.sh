#!/bin/bash
screen -ls > /dev/null 2>&1
if [ $? -eq 0 ]
then
screen -r
else
screen -S `whoami` /mnt/NovelloShell/novelloshell-v5.sh
fi
