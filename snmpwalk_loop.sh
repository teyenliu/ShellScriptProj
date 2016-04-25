#!/bin/bash

x=0
while [ $x -le 18 ]
do
    (( x++ ))
    #echo $x
    snmpbulkwalk -v2c -cpublic "10.3.207.40" "1.3.6.1.2.1.31.1.1.1."$x".13"
done