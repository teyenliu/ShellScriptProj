#!/bin/bash
# Program
#       Use ping command to check the network's PC state.
# History
# 2009/02/18    VBird   first release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
network="10.3.207"              # .............
for sitenu in $(seq 1 100)       # seq . sequence(..) .....
do
    # ........ ping ..............
    ping -c 1 -w 1 ${network}.${sitenu} &> /dev/null && result=0 || result=1
    # ............ (UP) ......... (DOWN)
    if [ "$result" == 0 ]; then
        echo "Server ${network}.${sitenu} is UP."
    else
        echo "Server ${network}.${sitenu} is DOWN."
    fi
done