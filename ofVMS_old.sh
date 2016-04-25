#! /bin/bash
export PATH=$PATH:/home/minchi/noxcore/src/utilities

xterm -e monitor end1&
xterm -e monitor end2&
xterm -e monitor openflow1&

cd vm/
start-test-vm --vmm=qemu vms-1sw-2hsts.conf

