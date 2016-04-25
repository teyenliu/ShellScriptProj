#!/bin/bash
croton_ports=(1 2 3 4 5 6 7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28)
hudson_ports=(2 3 4 5 7 8 9 10 12 13 14 15 17 18 19 20 22 23 24 25 27 28 29 30 32 33 34 35)

for (( i=27; i>=0; i-- ))
do
   find ./ -name "*.txt" | xargs -i sed -i "s/0\/${croton_ports[i]}$/0\/${hudson_ports[i]}/g" {}
   find ./ -name "*.txt" | xargs -i sed -i "s/0\/${croton_ports[i]}-/0\/${hudson_ports[i]}-/g" {}
   find ./ -name "*.txt" | xargs -i sed -i "s/0\/${croton_ports[i]} /0\/${hudson_ports[i]} /g" {}
done

find ./ -name "*.txt" | xargs -i sed -i "s/'Hudson'/'HudsonBay'/g" {}
