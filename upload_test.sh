#!/bin/bash

image_ist="GeminiPortal;Solution/Openstack\ Image/Ubuntu14.04.raw,Windows7;Solution/Openstack\ Image/Windows7.raw"

for i in $(echo $image_list | tr "," "\n")
do
    echo "==>$i"
    IFS=";"; read -ra DATA <<< "$i"
    echo "${DATA[0]}"  
    echo "${DATA[1]}" 
done
        