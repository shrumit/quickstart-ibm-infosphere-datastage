#!/bin/bash
namespace=NAME-SPACE
if [[ -z $namespace ]]; then
namespace="prod"
fi

#Get the xmeta pod name
xmetapod=`kubectl get pods -n $namespace|grep xmetadocker|awk '{print $1}'`

#Creating folders in pod for storing config files backup
echo "Creating Directories in Pod!!!"
kubectl exec -i $xmetapod -n $namespace -- bash -c "sudo mkdir -p /mnt/IIS_$namespace/aws"
kubectl exec -i $xmetapod -n $namespace -- bash -c "sudo mkdir -p /mnt/IIS_$namespace/aws/db2; chmod -R 777 /mnt/IIS_$namespace/aws/db2"
kubectl exec -i $xmetapod -n $namespace -- bash -c "sudo mkdir -p /mnt/IIS_$namespace/aws/db2/FullBackup; chmod -R 777 /mnt/IIS_$namespace/aws/db2/FullBackup"
kubectl exec -i $xmetapod -n $namespace -- bash -c "sudo mkdir -p /mnt/IIS_$namespace/aws/db2/IncrementalBackup; chmod -R 777 /mnt/IIS_$namespace/aws/db2/IncrementalBackup"
kubectl exec -i $xmetapod -n $namespace -- bash -c "sudo mkdir -p /mnt/IIS_$namespace/aws/istools; chmod -R 777 /mnt/IIS_$namespace/aws/istools"
