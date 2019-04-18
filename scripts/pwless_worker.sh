#!/bin/bash -e
# Retrieve RSA key and append to authorized_keys
ORDER_ID=$1

while ! PUB="$(aws ssm get-parameter --name /${ORDER_ID}/master_rsa_pub --with-decryption --query Parameter.Value --output text)"; do sleep 5; done

cp /root/.ssh/authorized_keys /root/.ssh/authorized_keys.orig
echo $PUB | tr '*' '\n' >> /root/.ssh/authorized_keys

systemctl restart sshd
