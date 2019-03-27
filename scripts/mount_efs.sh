#!/bin/bash -e
REGION=$1
EFSID=$2

mkdir -p /efs
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${EFSID}.efs.${REGION}.amazonaws.com:/ /efs
echo "${EFSID}.efs.${REGION}.amazonaws.com:/  /efs  nfs4  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev  0  0" >> /etc/fstab
mount --bind /efs /mnt
echo '/efs  /mnt  none  bind' >> /etc/fstab
