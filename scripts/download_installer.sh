#!/bin/bash


ICN=$1
PN=$2
REGION=$3
ENDPOINT='https://onpd230guk.execute-api.ca-central-1.amazonaws.com/default/microservice/'


# try API call 5 times
n=0
while [ $n -ne 5 ]
do
  RESPONSE="$(curl -s --fail -d "{\"icn\": \"${ICN}\", \"part_number\": \"${PN}\", \"region\":\"${REGION}\"}" -H 'Content-Type: application/json' -X POST $ENDPOINT)" && break
  n=$[$n+1]
  sleep 5
done

if [ $n -eq 5 ]
then
    exit 1
fi

DIRPATH=/disk1/quickstart/installer
mkdir -p $DIRPATH

# download files in parallel
N_FILES=$(echo $RESPONSE | jq '.assets | length')
for ((i = 0 ; i < N_FILES ; i++ )); do
  echo $RESPONSE | jq -r ".assets[$i] | \"$DIRPATH/\" + .key + \" \" + .url"  | xargs -n 2 bash -c 'curl -s -o $0 $1' &
  PIDS[$i]=$!
done
for PID in ${PIDS[*]}; do
  wait $PID
done

# remove suffix
if [ ! -f $DIRPATH/ds-docker-11.7.0.2-1.0.tar.gz ]; then
  mv $DIRPATH/ds-docker-11.7.0.2-1.0*.tar.gz $DIRPATH/ds-docker-11.7.0.2-1.0.tar.gz
fi
if [ ! -f $DIRPATH/DS-Kube-Installer-11.7.tar.gz ]; then
  mv $DIRPATH/DS-Kube-Installer-11.7*.tar.gz $DIRPATH/DS-Kube-Installer-11.7.tar.gz
fi
cd $DIRPATH
tar -xzf DS-Kube-Installer-11.7.tar.gz
