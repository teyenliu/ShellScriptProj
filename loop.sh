#!/bin/bash
c=0
while [ $c -le 272 ]
do
	(( c++ ))
        name=`printf "%03d" $c`
	echo $name
	wget "http://www.ept-cn.com/voa/mp3/$name.mp3"
done
