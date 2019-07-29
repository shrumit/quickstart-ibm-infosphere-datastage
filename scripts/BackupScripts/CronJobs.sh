crontab <<EOF
0 0 * * 0 sudo BASE_DIR/BackupScripts/db2FullBackup.sh > /tmp/db2FullBackup.txt 2>&1
30 0 * * 1-6 sudo BASE_DIR/BackupScripts/db2IncrementalBackup.sh > /tmp/db2IncrementalBackup.txt 2>&1
0 1 * * 1-5 sudo BASE_DIR/BackupScripts/istool_assets.sh > /tmp/istool_assets.txt 2>&1
EOF