#!/bin/bash -e

ORDER_ID=$1

while ! MASTER2="$(aws ssm get-parameter --name /${ORDER_ID}/master2_ip --query Parameter.Value --output text)"; do sleep 5; done
while ! MASTER3="$(aws ssm get-parameter --name /${ORDER_ID}/master3_ip --query Parameter.Value --output text)"; do sleep 5; done

systemctl daemon-reload
systemctl enable new-worker-listener
systemctl start new-worker-listener

ssh -o StrictHostKeyChecking=no -T $MASTER2 << EOF
    systemctl daemon-reload
    systemctl enable new-worker-listener
    systemctl start new-worker-listener
EOF

ssh -o StrictHostKeyChecking=no -T $MASTER3 << EOF
    systemctl daemon-reload
    systemctl enable new-worker-listener
    systemctl start new-worker-listener
EOF
