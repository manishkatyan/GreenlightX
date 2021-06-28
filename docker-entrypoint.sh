#!/bin/bash
# Cleanup to be "stateless" on startup, otherwise pulseaudio daemon can't start
rm -rf /var/run/pulse /var/lib/pulse /root/.config/pulse

#Start pulseaudio as system wide daemon; for debugging it helps to start in non-daemon mode
# pulseaudio --start -vvv --disallow-exit --log-target=syslog --high-priority --exit-idle-time=-1 &
pulseaudio -D --verbose --exit-idle-time=-1 --system --disallow-exit
