#!/bin/bash
#description: this script run EasyConnect and handle error about sslservice
#author:du33169

#the sudo password
key=

if [ -z "$key" ] ; then
    echo "fatal: sudo key is empty! Exiting..."
    exit 1
fi
#check if EasyMonitor is running
checkECM=$(ps aux|grep EasyMonitor|grep -v grep)
if [ -z "$checkECM" ] ; then # not running, launch it
    echo "EasyMonitor not running, launching it..."
    echo ${key}|sudo -S /usr/share/sangfor/EasyConnect/resources/shell/EasyMonitor.sh start&
fi

#launch main client program 
/usr/share/sangfor/EasyConnect/resources/shell/EasyConnect.sh 2>/dev/null&
#wait for error in log
echo ${key}|sudo -S tail -n 0 -f /usr/share/sangfor/EasyConnect/resources/logs/ECAgent.log | grep "\\[Register\\]cms client connect failed" -m 1
#expected error ocurred, run the sslservice
echo ${key}|sudo -S /usr/share/sangfor/EasyConnect/resources/shell/sslservice.sh
# waiting for main program to end
while [ -n "$(ps -e|grep EasyConnect|grep -v RunEasyConnect)" ] ; do
        sleep 1
done
echo "main program stopped, exiting..."
