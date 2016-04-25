#!/bin/bash

. func_libs

for server in $(cat serverlist)
do
    ping -o $server > /dev/null 2>&1
    if [ $? -eq 0 ] ; then
        echo_bold “$server = running”
    else
        echo_bold “$server = not running”
    fi
done