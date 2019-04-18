#!/bin/bash -e
while ! INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"; do sleep 5; done

aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --source-dest-check "{\"Value\": false}"
