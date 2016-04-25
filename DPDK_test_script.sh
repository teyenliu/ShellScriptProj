# Update Grub
GRUB_CMDLINE_LINUX_DEFAULT="... default_hugepagesz=1G hugepagesz=1G hugepages=16 hugepagesz=2M hugepages=2048 iommu=pt intel_iommu=on isolcpus=1-13,15-27"
update-grub

# Export Variables
export OVS_DIR=/root/soucecode/ovs
export DPDK_DIR=/root/soucecode/dpdk-2.1.0
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
locale-gen "en_US.UTF-8"
dpkg-reconfigure locales

# build DPDK
curl -O http://dpdk.org/browse/dpdk/snapshot/dpdk-2.1.0.tar.gz
tar -xvzf dpdk-2.1.0.tar.gz
cd $DPDK_DIR
sed 's/CONFIG_RTE_BUILD_COMBINE_LIBS=n/CONFIG_RTE_BUILD_COMBINE_LIBS=y/' -i config/common_linuxapp
make install T=x86_64-ivshmem-linuxapp-gcc
cd $DPDK_DIR/x86_64-ivshmem-linuxapp-gcc
EXTRA_CFLAGS="-g -Ofast" make -j10

# build OVS
git clone https://github.com/openvswitch/ovs.git
cd $OVS_DIR
./boot.sh
./configure --with-dpdk="$DPDK_DIR/x86_64-ivshmem-linuxapp-gcc/" CFLAGS="-g -Ofast"
make 'CFLAGS=-g -Ofast -march=native' -j10

# Setup OVS
pkill -9 ovs
rm -rf /usr/local/var/run/openvswitch
rm -rf /usr/local/etc/openvswitch/
rm -f /usr/local/etc/openvswitch/conf.db
mkdir -p /usr/local/etc/openvswitch
mkdir -p /usr/local/var/run/openvswitch
cd $OVS_DIR
./ovsdb/ovsdb-tool create /usr/local/etc/openvswitch/conf.db ./vswitchd/vswitch.ovsschema
./ovsdb/ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --pidfile --detach
./utilities/ovs-vsctl --no-wait init

# Check IOMMU & Huge info
cat /proc/cmdline
grep Huge /proc/meminfo

# Setup Hugetable
mkdir -p /mnt/huge
mkdir -p /mnt/huge_2mb
mount -t hugetlbfs hugetlbfs /mnt/huge
mount -t hugetlbfs none /mnt/huge_2mb -o pagesize=2MB
 
# Bind Ether card
modprobe vfio-pci
cd $DPDK_DIR/tools
./dpdk_nic_bind.py --status
./dpdk_nic_bind.py --bind=vfio-pci 08:00.2

# Start OVS
modprobe openvswitch
$OVS_DIR/vswitchd/ovs-vswitchd --dpdk -c 0x2 -n 4 --socket-mem 2048 -- unix:/usr/local/var/run/openvswitch/db.sock --pidfile --detach

# Setup dpdk vhost user port
$OVS_DIR/utilities/ovs-vsctl show
$OVS_DIR/utilities/ovs-vsctl add-br br0 -- set bridge br0 datapath_type=netdev
$OVS_DIR/utilities/ovs-vsctl add-port br0 dpdk0 -- set Interface dpdk0 type=dpdk
$OVS_DIR/utilities/ovs-vsctl add-port br0 vhost-user1 -- set Interface vhost-user1 type=dpdkvhostuser
$OVS_DIR/utilities/ovs-vsctl add-port br0 vhost-user2 -- set Interface vhost-user2 type=dpdkvhostuser

find /sys/kernel/iommu_groups/ -type l

# Create VMs
qemu-system-x86_64 -m 1024 -smp 4 -cpu host -hda /tmp/vm1.qcow2 -boot c -enable-kvm -no-reboot -nographic -net none \
-chardev socket,id=char1,path=/usr/local/var/run/openvswitch/vhost-user1 \
-netdev type=vhost-user,id=mynet1,chardev=char1,vhostforce \
-device virtio-net-pci,mac=00:00:00:00:dd:01,netdev=mynet1 \
-object memory-backend-file,id=mem,size=1024M,mem-path=/dev/hugepages,share=on \
-numa node,memdev=mem -mem-prealloc
 
qemu-system-x86_64 -m 1024 -smp 4 -cpu host -hda /tmp/vm2.qcow2 -boot c -enable-kvm -no-reboot -nographic -net none \
-chardev socket,id=char1,path=/usr/local/var/run/openvswitch/vhost-user2 \
-netdev type=vhost-user,id=mynet1,chardev=char1,vhostforce \
-device virtio-net-pci,mac=00:00:00:00:dd:02,netdev=mynet1 \
-object memory-backend-file,id=mem,size=1024M,mem-path=/dev/hugepages,share=on \
-numa node,memdev=mem -mem-prealloc














===================================== Issues ====================================
Question 1:

I get the following error when attempting to start the guest:
vfio: error, group $GROUP is not viable, please ensure all devices within the iommu_group are bound to their vfio bus driver.
Answer:

There are more devices in the IOMMU group than you're assigning, they all need to be bound to the vfio bus driver (vfio-pci) or pci-stub for the group to be viable.  See my previous post about IOMMU groups for more information.  To reduce the size of the IOMMU group, install the device into a different slot, try a platform that has better isolation support, or (at your own risk) bypass ACS using the ACS override patch.
