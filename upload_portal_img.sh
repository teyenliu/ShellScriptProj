#!/bin/sh
# The example of exec this shell:
# sh upload_portal_img.sh 10.11.1.253 10.12.1.5 gemini-gocloud-portal-django-1-7.img

if [ $# -eq 0 ] ; then
    echo "No arguments supplied..."
    exit 1;
fi

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "We need the arguments"
else
    fuel_ip=$1
    controller_ip=$2
    image_name=$3
fi

# copy key file
scp root@"$fuel_ip":/root/.ssh/id_rsa ./stack.key
if [ ! -e "stack.key" ]; then
  exit 1;
fi

ssh -i ./stack.key root@"$controller_ip" '
apt-get install -y nfs-common
source openrc
mkdir -p /opt/file_server
mount -t nfs 172.16.200.50:/Gemini /opt/file_server

# upload image to openstack
glance image-create --name=GeminiPortal --is-public true \
          --disk-format raw --container-format bare \
          --file "/opt/file_server/\[02\]Images/Solutions/portal/$image_name"

until umount /opt/file_server ; then
do
    sleep 0.1
done

if mount | grep "/opt/file_server" > /dev/null; then
    echo "Fail to umount /opt/file_server" 
else
    #rm -rf /opt/file_server
fi

if glance image-list | grep "GeminiPortal"; then
  echo "successfully upload portal image"
else
  exit 1
fi
'
rm ./stack.key


