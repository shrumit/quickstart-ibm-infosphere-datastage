#!/bin/bash
# install AWS CLI
cd /tmp
yum install -y unzip
curl 'https://s3.amazonaws.com/aws-cli/awscli-bundle.zip' -o 'awscli-bundle.zip'
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/aws -b /usr/bin/aws
