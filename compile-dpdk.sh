#!/bin/sh
export RTE_SDK=/root/handson/dpdk-1.7.0
export RTE_TARGET=x86_64-native-linuxapp-gcc

cd $RTE_SDK
make install T=${RTE_TARGET}



#!/bin/sh
$ export RTE_SDK=/home/liudanny/git/DPDK-1.6.0
$ export RTE_TARGET="x86_64-default-linuxapp-gcc"
$ make config T=${RTE_TARGET}
$ make install T=${RTE_TARGET}