#!/bin/bash -e
# CURRENTLY ONLY WORKS WITH NVME-EBS INSTANCE TYPES
mkdir -p /disk1
mkfs -t xfs /dev/nvme1n1
mount /dev/nvme1n1 /disk1
UUID=$(blkid /dev/nvme1n1 -s UUID -o value)
echo "UUID=$UUID  /disk1  xfs  defaults,nofail  0  2" >> /etc/fstab
