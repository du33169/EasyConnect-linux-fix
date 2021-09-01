#!/bin/bash
checkECM=$(ps aux|grep EasyMonitor|grep -v grep)
if [$checkECM];then
    /usr/share/sangfor/EasyConnect/resources/shell/EasyMonitor.sh&
fi
/usr/share/sangfor/EasyConnect/resources/shell/EasyConnect.sh&
tail -n 0 -f /usr/share/sangfor/EasyConnect/resources/logs/ECAgent.log | grep "\\[Register\\]cms client connect failed" -m 1
/usr/share/sangfor/EasyConnect/resources/shell/sslservice.sh
