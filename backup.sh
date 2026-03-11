#!/bin/bash
backupserverip="192.168.56.20"
backupusername="backupuser"
backuproot="/backups/server1"
logfolder="/data/"

timestamp=$(date +%Y-%m-%d_%H-%M-%S)
finaldest="$backuproot/$timestamp"
logfile="$logfolder/backup_$timestamp.log"

mkdir -p "$logfolder"
exec > >(tee -a "$logfile") 2>&1

ssh -i ~/.ssh/id_rsa -o ConnectTimeout=5 "$backupusername@$backupserverip" "exit"
if [ $? -ne 0 ]; then
    echo "Server connection failed"
    exit 1
fi

ssh "$backupusername@$backupserverip" "mkdir -p '$finaldest'"
if [ $? -ne 0 ]; then
    echo "Cannot create folder"
    exit 1
fi

rsync -avz -e "ssh -i ~/.ssh/id_rsa" --exclude='lost+found' /data/ "$backupusername@$backupserverip:$finaldest/data/"
if [ $? -ne 0 ]; then
    echo "Cannot copy data"
    exit 1
fi

ssh "$backupusername@$backupserverip" "mkdir -p $finaldest/configs"
rsync -avz /etc/fstab /etc/ssh/sshd_config "$backupusername@$backupserverip:$finaldest/configs"
if [ $? -ne 0 ]; then
    echo "Cannot copy config"
    exit 1
fi
exit 0
