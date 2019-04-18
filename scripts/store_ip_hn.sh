#!/bin/bash
ORDER_ID=$1
PREFIX=$(cat /var/instance_prefix)
while ! HN="$(curl -s http://169.254.169.254/latest/meta-data/local-hostname)"; do sleep 5; done
while ! IP="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"; do sleep 5; done

aws ssm put-parameter --name /${ORDER_ID}/${PREFIX}_fqdn --type String --value $HN --overwrite
aws ssm put-parameter --name /${ORDER_ID}/${PREFIX}_ip --type String --value $IP --overwrite
