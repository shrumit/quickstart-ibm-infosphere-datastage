#!/bin/bash -e
ORDER_ID=$1

while ! PUB="$(aws ssm get-parameter --name /${ORDER_ID}/master_rsa_pub --with-decryption --query Parameter.Value --output text)"; do sleep 5; done
while ! PRIV="$(aws ssm get-parameter --name /${ORDER_ID}/master_rsa_priv --with-decryption --query Parameter.Value --output text)"; do sleep 5; done

cp /root/.ssh/authorized_keys /root/.ssh/authorized_keys.orig
echo $PUB | tr '*' '\n' >> /root/.ssh/authorized_keys
echo $PUB | tr '*' '\n' > /root/.ssh/id_rsa.pub
echo $PRIV | tr '*' '\n' > /root/.ssh/id_rsa

chmod 600 /root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/id_rsa

systemctl restart sshd
