#!/bin/bash -e

CLIENT=$1
CLIENT_IP=$2
NLB=$(echo $3 | tr '[:upper:]' '[:lower:]') # necessary because Kubernetes bug doesn't accept uppercase in URLs
ORDER_ID=$4

while ! THIS_MASTER=$(curl -s http://169.254.169.254/latest/meta-data/local-hostname); do sleep 5; done
while ! THIS_MASTER_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4); do sleep 5; done
while ! MASTER1=$(aws ssm get-parameter --name /${ORDER_ID}/master1_fqdn --query Parameter.Value --output text); do sleep 5; done
while ! MASTER1_IP=$(aws ssm get-parameter --name /${ORDER_ID}/master1_ip --query Parameter.Value --output text); do sleep 5; done
while ! MASTER2=$(aws ssm get-parameter --name /${ORDER_ID}/master2_fqdn --query Parameter.Value --output text); do sleep 5; done
while ! MASTER2_IP=$(aws ssm get-parameter --name /${ORDER_ID}/master2_ip --query Parameter.Value --output text); do sleep 5; done
while ! MASTER3=$(aws ssm get-parameter --name /${ORDER_ID}/master3_fqdn --query Parameter.Value --output text); do sleep 5; done
while ! MASTER3_IP=$(aws ssm get-parameter --name /${ORDER_ID}/master3_ip --query Parameter.Value --output text); do sleep 5; done
while ! WORKER1=$(aws ssm get-parameter --name /${ORDER_ID}/worker1_fqdn --query Parameter.Value --output text); do sleep 5; done
while ! WORKER1_IP=$(aws ssm get-parameter --name /${ORDER_ID}/worker1_ip --query Parameter.Value --output text); do sleep 5; done
while ! WORKER2=$(aws ssm get-parameter --name /${ORDER_ID}/worker2_fqdn --query Parameter.Value --output text); do sleep 5; done
while ! WORKER2_IP=$(aws ssm get-parameter --name /${ORDER_ID}/worker2_ip --query Parameter.Value --output text); do sleep 5; done

cat /disk1/quickstart/datastageinfo_partial.json     |
 jq ".distributedFileServer=\"$THIS_MASTER\""        |
 jq ".loadBalancerIP=\"$NLB\""                       |
 jq ".clientHosts[0].name=\"$CLIENT\""               |
 jq ".clientHosts[0].privateIP=\"$CLIENT_IP\""       |
 jq ".masterNodeHosts[0].name=\"$MASTER3\""          |
 jq ".masterNodeHosts[0].privateIP=\"$MASTER3_IP\""  |
 jq ".masterNodeHosts[1].name=\"$MASTER2\""          |
 jq ".masterNodeHosts[1].privateIP=\"$MASTER2_IP\""  |
 jq ".masterNodeHosts[2].name=\"$MASTER1\""          |
 jq ".masterNodeHosts[2].privateIP=\"$MASTER1_IP\""  |
 jq ".workerNodeHosts[0].name=\"$WORKER1\""          |
 jq ".workerNodeHosts[0].privateIP=\"$WORKER1_IP\""  |
 jq ".workerNodeHosts[1].name=\"$WORKER2\""          |
 jq ".workerNodeHosts[1].privateIP=\"$WORKER2_IP\""  |
 jq . > /disk1/quickstart/datastageinfo.json

cat /disk1/quickstart/nodes_partial.json          |
 jq ".masterNodeHost=\"$THIS_MASTER\""            |
 jq ".distributedFileServer=\"$THIS_MASTER\""     |
 jq . > /disk1/quickstart/nodes.json

# command = 'cat /disk1/quickstart/DS-Kube-Installer/nodes.json | jq ".workerNodeHost[0]=\'%s\'"' % form["hostname"].value
