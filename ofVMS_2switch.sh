#! /bin/bash
export PATH=$PATH:/home/minchi/noxcore/src/utilities

xterm -e monitor end1&
xterm -e monitor end2&
xterm -e monitor openflow1&

xterm -e monitor end3&
xterm -e monitor end4&
xterm -e monitor openflow2&
cd vm1/
start-test-vm --vmm=qemu vms-1sw-2hsts_2.conf

