#!/bin/bash

for x in $(egrep -o "ERROR" $1 | sort | uniq) ;
do
	echo -n -e "processing $x\t"
	grep -c "$x" $1
done