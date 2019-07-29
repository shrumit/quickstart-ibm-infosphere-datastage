#!/bin/bash
namespace=NAME-SPACE
if [[ -z $namespace ]]; then
namespace="prod"
fi

DateDir=`date +%Y-%m-%d-%H-%M`

#Get the xmeta pod name
xmetapod=`kubectl get pods -n $namespace|grep xmetadocker|awk '{print $1}'`

#Taking db2 Incremental backup.
kubectl exec -i $xmetapod -n $namespace -- bash -c "mkdir -p /mnt/IIS_$namespace/aws/db2/IncrementalBackup/$DateDir; chmod -R 777 /mnt/IIS_$namespace/aws/db2/IncrementalBackup/$DateDir"

kubectl exec -i $xmetapod -n $namespace -- bash -c "sudo su - db2inst1 -c \" db2 backup database XMETA online incremental TO /mnt/IIS_$namespace/aws/db2/IncrementalBackup/$DateDir; db2 backup database DSODB online incremental TO /mnt/IIS_$namespace/aws/db2/IncrementalBackup/$DateDir \""

retentiondate=`date +%Y%m%d -d "30 days ago"`
echo "Deleting database history from $retentiondate"

echo "Executing command : db2 prune history $retentiondate and delete"
cmdStr1='db2 connect to XMETA ; db2 prune history '$retentiondate
cmdStr2=' AND DELETE ; db2 terminate'
cmdStr3="${cmdStr1}${cmdStr2}"
kubectl exec -i $xmetapod -n $namespace -- bash -c "su - db2inst1 -c \"$cmdStr3\""

cmdStr4='db2 connect to DSODB ; db2 prune history '$retentiondate
cmdStr5=' AND DELETE ; db2 terminate'
cmdStr6="${cmdStr4}${cmdStr5}"
kubectl exec -i $xmetapod -n $namespace -- bash -c "su - db2inst1 -c \"$cmdStr6\""

#Delete folders older then 30 days.
kubectl exec -i $xmetapod -n $namespace -- bash -c "sudo find /mnt/IIS_$namespace/aws/db2/IncrementalBackup/* -type d -mtime +30 | xargs rm -rf"
