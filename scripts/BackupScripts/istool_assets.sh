#!/bin/bash
namespace=NAME-SPACE
if [[ -z $namespace ]]; then
namespace="prod"
fi

DateDir=`date +%Y-%m-%d-%H-%M`

#Get the servicesdocker pod name
servicepod=`kubectl get pods -n $namespace|grep is-servicesdocker|awk '{print $1}'`
PASSWORD='REPLACE_PASSWORD'

kubectl exec -i is-en-conductor-0 -n $namespace -- bash -c "sudo  mkdir -p /mnt/IIS_$namespace/aws/istools/$DateDir; chmod -R 777 /mnt/IIS_$namespace/aws/istools/$DateDir"

#Delete folders older then 30 days.
kubectl exec -i is-en-conductor-0 -n $namespace -- bash -c "sudo find /mnt/IIS_$namespace/aws/istools/* -type d -mtime +30 | xargs rm -rf"

kubectl exec -i is-en-conductor-0 -n $namespace -- bash -c "sudo /opt/IBM/InformationServer/Clients/istools/cli/istool.sh export -dom is-servicesdocker:9446 -u isadmin -p $PASSWORD -archive \"/mnt/IIS_$namespace/aws/istools/$DateDir/allassets.isx\" -all"

kubectl exec -i is-en-conductor-0 -n $namespace -- bash -c "sudo /opt/IBM/InformationServer/Clients/istools/cli/istool.sh export -dom is-servicesdocker:9446 -u isadmin -p $PASSWORD -archive \"/mnt/IIS_$namespace/aws/istools/$DateDir/datastageassets.isx\" -datastage 'IS-EN-CONDUCTOR-0.EN-COND:31538/dstage1/*/*.* -includedependent -includeexecutable'"
