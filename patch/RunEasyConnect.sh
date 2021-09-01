#!/bin/sh
echo "info: make sure this script is running under sudo!"

#check if EasyMonitor is running
checkECM=$(ps aux|grep EasyMonitor|grep -v grep)
if [ ! $checkECM ] ; then # not running, launch it
    /usr/share/sangfor/EasyConnect/resources/shell/EasyMonitor.sh&
fi

#launch main client program 
/usr/share/sangfor/EasyConnect/resources/shell/EasyConnect.sh&

#wait for error in log
tail -n 0 -f /usr/share/sangfor/EasyConnect/resources/logs/ECAgent.log | grep "\\[Register\\]cms client connect failed" -m 1

#error ocurred, run the sslservice
/usr/share/sangfor/EasyConnect/resources/shell/sslservice.sh
