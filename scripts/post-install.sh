#!/bin/bash

# Constants
TEMPLATE_FILE='datastagetemplate.yaml'
SCC_FILE='scc-datastage.yaml'
KERNEL_FILE='set-kernel.yaml'

mkdir -p /quickstart
cd /quickstart
aws s3 cp ${ds_QS_S3URI}scripts/ . --recursive

ansible masters -a "htpasswd -b /etc/origin/master/htpasswd devuser $ds_IISPassword"
oc adm policy add-cluster-role-to-user cluster-admin devuser

oc new-project $ds_ProjectName
oc project $ds_ProjectName

oc delete storageclass glusterfs-storage
oc create -f $SCC_FILE
oc adm policy add-scc-to-user scc-datastage -z default

aws elb create-load-balancer-listeners \
 --region "$AWS_REGION" \
 --load-balancer-name "$CONTAINERACCESSELB" \
 --listeners "Protocol=TCP,LoadBalancerPort=9446,InstanceProtocol=TCP,InstancePort=443" "Protocol=TCP,LoadBalancerPort=31538,InstanceProtocol=TCP,InstancePort=32501" "Protocol=TCP,LoadBalancerPort=31531,InstanceProtocol=TCP,InstancePort=32502"
 
oc process -f $TEMPLATE_FILE \
 -p NAMESPACE=${ds_ProjectName} \
 -p APPLICATION_PASSWORD=$(echo -n $ds_IISPassword | base64) \
 -p CONTAINER_REGISTRY_PREFIX=${ds_RegistryPrefix} \
 -p DSCLIENT_PRIVATE_IP=${ds_DSClientPrivateIp} \
 -p ENGINE_VOL_SIZE="$((3*$ds_StorageSize/10))Gi" \
 -p SERV_VOL_SIZE="$((2*$ds_StorageSize/10))Gi" \
 -p REPO_VOL_SIZE="$((3*$ds_StorageSize/10))Gi" \
 | oc create -f -

oc create route passthrough is-servicesdocker \
 --service=is-servicesdocker \
 --hostname=$(echo $CONTAINERACCESSELB_DNS | tr '[:upper:]' '[:lower:]') \
 --port=is-servicesdocker-port

kubectl apply -f $KERNEL_FILE

# Wait for application to come up
# LaunchpadUrl="https://${CONTAINERACCESSELB_DNS}/ibm/iis/launchpad/"
# while ! $(curl -k -s -N "$LaunchpadUrl" | grep -q 'InfoSphere'); do echo 'waiting' && sleep 10; done
while ! $(oc logs is-en-conductor-0 | grep -q 'Initialization Complete.'); do echo 'waiting' && sleep 30; done
sleep 900
curl -d "${ds_ICN}" -X POST 'https://73js6q2hc0.execute-api.ca-central-1.amazonaws.com/default'
