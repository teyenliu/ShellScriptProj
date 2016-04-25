#!/bin/sh
export RTE_SDK=/root/handson/dpdk-1.7.0
export RTE_TARGET=x86_64-native-linuxapp-gcc

DPDK_NIC_PCIS="0000:00:14.0 0000:00:14.1 0000:00:14.2 0000:00:14.3"
HUGEPAGE_NOPAGES="1024"

set_numa_pages()
{
        for d in /sys/devices/system/node/node? ; do
                sudo sh -c "echo ${HUGEPAGE_NOPAGES} > $d/hugepages/hugepages-2048kB/nr_hugepages"
        done
}

set_no_numa_pages()
{
        sudo sh -c "echo ${HUGEPAGE_NOPAGES} > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"
}

# install module
sudo modprobe uio
sudo insmod ${RTE_SDK}/${RTE_TARGET}/kmod/igb_uio.ko
sudo insmod ${RTE_SDK}/${RTE_TARGET}/kmod/rte_kni.ko

# unbind e1000 NICs from igb and bind igb_uio for DPDK
sudo ${RTE_SDK}/tools/dpdk_nic_bind.py --bind=igb_uio  ${DPDK_NIC_PCIS}
sudo ${RTE_SDK}/tools/dpdk_nic_bind.py --status

# mount fugepagefs
echo "Set hugepagesize=${HUGEPAGE_NOPAGES} of 2MB page"
NCPUS=$(find /sys/devices/system/node/node?  -maxdepth 0 -type d | wc -l)

if [ ${NCPUS} -gt 1 ] ; then
        set_numa_pages
else
        set_no_numa_pages
fi

echo "Creating /mnt/huge and mounting as hugetlbfs"
sudo mkdir -p /mnt/huge
grep -s '/mnt/huge' /proc/mounts > /dev/null
if [ $? -ne 0 ] ; then
        sudo mount -t hugetlbfs nodev /mnt/huge
fi

unset RTE_SDK
unset RTE_TARGET
