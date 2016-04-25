#!/bin/bash

. func_libs

if [ $# -eq 0 ]
then
    echo_bold "Usage $0 your_service_name"
    exit 1
fi

service=$1
# another test condition example:
#(( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 )) 
is_running=`ps aux | grep -v grep| grep -v "$0" | grep $service| wc -l | awk '{print $1}'`

if [ $is_running != "0" ] ;
then
    echo_bold "Service $service is running"
else
    echo_bold
    initd=`ls /etc/init.d/ | grep $service | wc -l | awk '{ print $1 }'`

    if [ $initd = "1" ];
    then
        startup=`ls /etc/init.d/ | grep $service`
        echo -n "Found startap script /etc/init.d/${startup}. Start it? Y/n ? "

        read answer
        if [ $answer = "y" -o $answer = "Y" ];
        then
            echo_bold "Starting service..."
            /etc/init.d/${startup} start
        fi
    fi
fi