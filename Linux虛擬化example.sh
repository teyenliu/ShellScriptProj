#!/bin/sh

delete() {
    sudo ovs-vsctl del-br vswitch1
    sudo ovs-vsctl del-br vswitch2
    sudo ip netns delete vhost1
    sudo ip netns delete vhost2
    sudo ip netns delete vhost3
    sudo ip netns delete vhost4
    sudo ip link delete vlink5-0
    sudo ip link delete vlink5-1
    sudo ip netns delete vrouter1

}

add() {
    sudo ovs-vsctl add-br vswitch1
    sudo ovs-vsctl add-br vswitch2
    
    sudo ip link add name vlink1-0 type veth peer name vlink1-1
    sudo ip link add name vlink2-0 type veth peer name vlink2-1
    sudo ip link add name vlink3-0 type veth peer name vlink3-1
    sudo ip link add name vlink4-0 type veth peer name vlink4-1
    sudo ip link add name vlink5-0 type veth peer name vlink5-1
    sudo ip link add name vlink6-0 type veth peer name vlink6-1
    sudo ip link add name vlink7-0 type veth peer name vlink7-1
    
    sudo ip link set vlink1-0 up
    sudo ip link set vlink2-0 up
    sudo ip link set vlink3-0 up
    sudo ip link set vlink4-0 up
    sudo ip link set vlink6-0 up
    sudo ip link set vlink7-0 up
    
    sudo ip link set vlink1-1 up
    sudo ip link set vlink2-1 up
    sudo ip link set vlink3-1 up
    sudo ip link set vlink4-1 up
    sudo ip link set vlink6-1 up
    sudo ip link set vlink7-1 up
    
    sudo ip netns add vhost1
    sudo ip netns add vhost2
    sudo ip netns add vhost3
    sudo ip netns add vhost4
    sudo ip netns add vrouter1
    
    sudo ip netns exec vhost1 ifconfig lo 127.0.0.1
    sudo ip netns exec vhost2 ifconfig lo 127.0.0.1
    sudo ip netns exec vhost3 ifconfig lo 127.0.0.1
    sudo ip netns exec vhost4 ifconfig lo 127.0.0.1
    sudo ip netns exec vrouter1 ifconfig lo 127.0.0.1

    sudo ip link set vlink1-0 netns vhost1
    sudo ip link set vlink2-0 netns vhost2
    sudo ip link set vlink3-0 netns vhost3
    sudo ip link set vlink4-0 netns vhost4

    sudo ip link set vlink6-0 netns vrouter1
    sudo ip link set vlink7-0 netns vrouter1
    
    sudo ip netns exec vhost1 ifconfig vlink1-0 192.168.1.1 netmask 255.255.255.0
    sudo ip netns exec vhost2 ifconfig vlink2-0 192.168.2.1 netmask 255.255.255.0
    sudo ip netns exec vhost3 ifconfig vlink3-0 192.168.1.2 netmask 255.255.255.0
    sudo ip netns exec vhost4 ifconfig vlink4-0 192.168.2.2 netmask 255.255.255.0

    sudo ip netns exec vrouter1 ifconfig vlink6-0 192.168.1.3 netmask 255.255.255.0
    sudo ip netns exec vrouter1 ifconfig vlink7-0 192.168.2.3 netmask 255.255.255.0
    
    sudo ovs-vsctl add-port vswitch1 vlink5-0
    sudo ovs-vsctl add-port vswitch2 vlink5-1
    
    sudo ovs-vsctl add-port vswitch1 vlink1-1 tag=10
    sudo ovs-vsctl add-port vswitch1 vlink2-1 tag=20
    
    sudo ovs-vsctl add-port vswitch2 vlink3-1 tag=10
    sudo ovs-vsctl add-port vswitch2 vlink4-1 tag=20

    sudo ovs-vsctl add-port vswitch1 vlink6-1 tag=10
    sudo ovs-vsctl add-port vswitch1 vlink7-1 tag=20

    sudo ip link set vlink5-0 up
    sudo ip link set vlink5-1 up

    sudo ip netns exec vhost1 route add default gw 192.168.1.3
    sudo ip netns exec vhost2 route add default gw 192.168.2.3
    sudo ip netns exec vhost3 route add default gw 192.168.1.3
    sudo ip netns exec vhost4 route add default gw 192.168.2.3
}

case "$1" in
add)
    set -x
    add
    ;;
delete)
    delete > /dev/null 2>&1
    ;;
*)
    echo "usage: $0 (add|delete)"
esac