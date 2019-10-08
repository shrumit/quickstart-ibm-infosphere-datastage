#!/bin/bash

NAMESPACE=$1
if [[ -z $NAMESPACE ]]; then
  echo 'Usage: ./DB2_IncrementalBackup.sh <projectname>'
  exit 1
fi

#Get the xmeta pod name
xmetapod=`oc get pods -n $NAMESPACE | grep xmetadocker | awk '{print $1}'`

#Taking db2 Incremental Backup.
oc exec -i $xmetapod -n $NAMESPACE -- bash -c "sudo su - db2inst1 -c \"cd /home/db2inst1; db2 backup database xmeta online include logs; db2 backup database dsodb online include logs; \""

oc exec -i $xmetapod -n $NAMESPACE -- bash -c "sudo su - db2inst1 -c \"cd /home/db2inst1; db2 backup database XMETA online incremental; db2 backup database DSODB online incremental \""
