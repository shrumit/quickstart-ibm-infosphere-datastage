#!/bin/bash
namespace=NAME-SPACE
if [[ -z $namespace ]]; then
namespace="prod"
fi

DateDir=`date +%Y-%m-%d-%H-%M`

#Get the xmeta pod name
xmetapod=`kubectl get pods -n $namespace|grep xmetadocker|awk '{print $1}'`

#Taking db2 Full backup.
kubectl exec -i $xmetapod -n $namespace -- bash -c "mkdir -p /mnt/IIS_$namespace/aws/db2/FullBackup/$DateDir; chmod -R 777 /mnt/IIS_$namespace/aws/db2/FullBackup/$DateDir"

kubectl exec -i $xmetapod -n $namespace -- bash -c "sudo su - db2inst1 -c \" db2 backup database xmeta online TO /mnt/IIS_$namespace/aws/db2/FullBackup/$DateDir include logs; db2 backup database dsodb online TO /mnt/IIS_$namespace/aws/db2/FullBackup/$DateDir include logs; \""

#Delete folders older then 30 days.
kubectl exec -i $xmetapod -n $namespace -- bash -c "sudo find /mnt/IIS_$namespace/aws/db2/FullBackup/* -type d -mtime +30 | xargs rm -rf"
