#!/bin/bash -e

ORDER_ID=$1
LABEL=$2

while ! HN="$(curl -s http://169.254.169.254/latest/meta-data/local-hostname)"; do sleep 5; done
while ! IP="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"; do sleep 5; done
while ! NLB="$(aws ssm get-parameter --name /${ORDER_ID}/master_nlb_dnsname --query Parameter.Value --output text)"; do sleep 5; done

curl -d "ip=${IP}&hostname=${HN}&label=${LABEL}" -X POST $NLB:8080/addWorker
