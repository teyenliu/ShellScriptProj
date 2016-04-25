#!/bin/bash                                                                          

intervalo=3                                                                          
info="/sys/class/net/"                                                               
cd $info                                                                             
for interface in eth*                                                                
do                                                                                   
    rx1=`cat $info$interface/statistics/rx_bytes`                                      
    tx1=`cat $info$interface/statistics/tx_bytes`                                      
    `sleep $((intervalo))s`                                                            
    rx2=`cat $info$interface/statistics/rx_bytes`                                      
    tx2=`cat $info$interface/statistics/tx_bytes`
    echo $interface
    echo ----
    echo RX: $((($rx2-$rx1)/($intervalo*1024))) Kbps
    echo TX: $((($tx2-$tx1)/($intervalo*1024))) Kbps
done