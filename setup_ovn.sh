#!/bin/bash

# Get host ip addr
HOST_IP=`ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`

# Start docker daemon with 
sudo docker daemon --cluster-store=consul://127.0.0.1:8500 \
--cluster-advertise=$HOST_IP:0

# The "overlay" mode
sudo ovs-appctl -t ovsdb-server ovsdb-server/add-remote ptcp:6640
sudo /usr/share/openvswitch/scripts/ovn-ctl start_northd

CENTRAL_IP=$HOST_IP
LOCAL_IP=$HOST_IP
ENCAP_TYPE="geneve"

# Start ovn-controller
sudo ovs-vsctl set Open_vSwitch . \
  external_ids:ovn-remote="tcp:$CENTRAL_IP:6642" \
  external_ids:ovn-nb="tcp:$CENTRAL_IP:6641" \
  external_ids:ovn-encap-ip=$LOCAL_IP \
  external_ids:ovn-encap-type="$ENCAP_TYPE"
