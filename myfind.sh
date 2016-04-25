#! /bin/bash
find . -name $1 -exec grep -n -H $2 {} \;
