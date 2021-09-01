#!/bin/bash
/usr/share/sangfor/EasyConnect/resources/bin/EasyMonitor&
/usr/share/sangfor/EasyConnect/EasyConnect --enable-transparent-visuals --disable-gpu&
while true
do
    tail -n 0 -f /usr/share/sangfor/EasyConnect/resources/logs/ECAgent.log | grep "\\[Register\\]cms client connect failed" -m 1
    /usr/share/sangfor/EasyConnect/resources/shell/sslservice.sh
    sleep 2
done
