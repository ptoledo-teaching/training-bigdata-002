#!/bin/bash
set -e
source credentials/aws/credentials.sh
echo "### Launching cluster"
flintrock --config config/flintrock/config.yaml launch spark-cluster
IP_MASTER=`flintrock --config config/flintrock/config.yaml describe spark-cluster | grep master: | awk '{print $2}'`
ssh -i keys/flintrock-sa-east-1.pem -o StrictHostKeyChecking=no ec2-user@$IP_MASTER 'ssh -o StrictHostKeyChecking=no ec2-user@$(hostname) "mkdir -p scripts"' 2>/dev/null
echo "### Configuring machines"
scp -i keys/flintrock-sa-east-1.pem scripts/master/* ec2-user@$IP_MASTER:~/scripts
scp -i keys/flintrock-sa-east-1.pem config/hadoop/* ec2-user@$IP_MASTER:~/hadoop/conf/
scp -i keys/flintrock-sa-east-1.pem config/spark/* ec2-user@$IP_MASTER:~/spark/conf/
ssh -i keys/flintrock-sa-east-1.pem -T ec2-user@$IP_MASTER << EOF
    sudo yum -y -q update
    echo 'export PATH=\$PATH:~/scripts' >> ~/.bashrc
    mkdir -p ~/data
    chmod +x ~/scripts/*.sh
    cp ~/hadoop/etc/hadoop/log4j.properties ~/hadoop/conf/
    echo "### Configuring workers"
    for slave in \$(cat ~/spark/conf/slaves); do
        echo \$slave
        ssh ec2-user@\$slave 'cp ~/hadoop/etc/hadoop/log4j.properties ~/hadoop/conf/' &
        scp ~/spark/conf/spark-defaults.conf ec2-user@\$slave:~/spark/conf/ &
        wait
    done
    echo "### Restarting hdfs"
    ~/hadoop/sbin/stop-dfs.sh 2>&1 | grep -v 'WARNING'
    ~/hadoop/sbin/start-dfs.sh 2>&1 | grep -v 'WARNING'
    echo "### Ready"
EOF
