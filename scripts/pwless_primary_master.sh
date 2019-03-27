#!/bin/bash -e
# Produce RSA key, append to authorized_keys and put in Parameter Store
ORDER_ID=$1

yes y | ssh-keygen -q -f /root/.ssh/id_rsa -N '' > /dev/null
cp /root/.ssh/authorized_keys /root/.ssh/authorized_keys.orig
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
systemctl restart sshd

aws ssm put-parameter --name /${ORDER_ID}/master_rsa_priv --type SecureString --value "$(cat /root/.ssh/id_rsa | tr '\n' '*')"
aws ssm put-parameter --name /${ORDER_ID}/master_rsa_pub --type SecureString --value "$(cat /root/.ssh/id_rsa.pub | tr '\n' '*')"
