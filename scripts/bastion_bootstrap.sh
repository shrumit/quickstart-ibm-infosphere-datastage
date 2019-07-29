#!/bin/bash

# download BackupScripts files
mkdir -p /home/ec2-user/BackupScripts
cd /home/ec2-user/BackupScripts
aws s3 cp s3://${DS_QSS3_COMBINED}scripts/BackupScripts/createPodDir.sh .
aws s3 cp s3://${DS_QSS3_COMBINED}scripts/BackupScripts/CronJobs.sh .
aws s3 cp s3://${DS_QSS3_COMBINED}scripts/BackupScripts/db2FullBackup.sh .
aws s3 cp s3://${DS_QSS3_COMBINED}scripts/BackupScripts/db2IncrementalBackup.sh .
aws s3 cp s3://${DS_QSS3_COMBINED}scripts/BackupScripts/istool_assets.sh .

chown ec2-user:ec2-user *
chmod u+x *

# download and continue original eks bastion_bootstrap.sh
cd /tmp
aws s3 cp s3://${DS_QSS3_COMBINED}submodules/quickstart-amazon-eks/scripts/bastion_bootstrap.sh ./bastion_bootstrap_eks.sh
chmod +x bastion_bootstrap_eks.sh
./bastion_bootstrap_eks.sh "$@"
