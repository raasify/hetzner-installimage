#!/bin/bash
# Execute with:
# bash <(curl -s https://raw.githubusercontent.com/raasify/hetzner-installimage/master/master-installimage.sh)

if [ "$1" == "" ]
then
  echo "Usage: ./$0 <hostname>"
  exit 1
fi 

. ~/.bashrc


HOSTNAME=${1}

cat << EOF > /tmp/install.conf

DRIVE1 /dev/nvme0n1
DRIVE2 /dev/nvme1n1

SWRAID 0

HOSTNAME ${HOSTNAME}

PART /boot ext3 512M
PART /     ext4 all

IMAGE /root/.oldroot/nfs/install/../images/Alma-85-amd64-base.tar.gz

EOF

cat << EOS > /tmp/postsetup.sh
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/nvme1n1
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
    # default - end at end of disk 
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF
mkfs.ext4 /dev/nvme1n1p1
echo /dev/nvme1n1p1 /data1 ext4 defaults 0 0 >> /etc/fstab
mkdir -p /data1
mount /data1
df -h / /data1
EOS

chmod 755 /tmp/postsetup.sh

# https://github.com/hetzneronline/installimage/blob/6358b0db57866bf0cffca657e3035deab7a77908/get_options.sh
installimage -c /tmp/install.conf -a -x /tmp/postsetup.sh


