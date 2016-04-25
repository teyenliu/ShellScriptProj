#! /bin/sh

SRCPATH="/home/tomcat/.jenkins/workspace/ICOS_for_Croton/output/FastPath-ICOS-esw-xgs4-gtr-NLR-CS-BD6IQH_OF/objects"

for f in `find . -name "*.sh" -print`; do
    echo $f
    n=${#f}
    echo $n
    n=`expr $n - 7`
    echo $n
    f=${f:4:$n}
    echo $f
done