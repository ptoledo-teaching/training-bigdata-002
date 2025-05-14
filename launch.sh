#!/bin/bash
set -e
source credentials/aws/credentials.sh
echo "### Launching cluster"
flintrock --config config/flintrock/config.yaml launch spark-cluster
IP_MASTER=`flintrock --config config/flintrock/config.yaml describe spark-cluster | grep master: | awk '{print $2}'`
ssh -i credentials/keys/flintrock-us-east-1.pem -o StrictHostKeyChecking=no ec2-user@$IP_MASTER 'ssh -o StrictHostKeyChecking=no ec2-user@$(hostname) "mkdir -p scripts"' 2>/dev/null
echo "### Transfering files to master node"
scp -i credentials/keys/flintrock-us-east-1.pem scripts/* ec2-user@$IP_MASTER:~/scripts
scp -i credentials/keys/flintrock-us-east-1.pem config/spark/* ec2-user@$IP_MASTER:~/spark/conf/
scp -i credentials/keys/flintrock-us-east-1.pem credentials/aws/credentials.sh ec2-user@$IP_MASTER:~/scripts
ssh -i credentials/keys/flintrock-us-east-1.pem -T ec2-user@$IP_MASTER << EOF
    echo "### Configuring master node"
    sudo yum -y -q update
    chmod +x ~/scripts/*.sh
    echo 'export PATH=\$PATH:~/scripts' >> ~/.bashrc
    chmod +x ~/scripts/*.sh
    echo "### Configuring worker nodes"
    for slave in \$(cat ~/spark/conf/slaves); do
        echo \$slave
        scp ~/spark/conf/spark-defaults.conf ec2-user@\$slave:~/spark/conf/ &
        wait
    done
EOF
echo "### Ready"
