source credentials.sh
flintrock --config config.yaml launch spark-cluster
IP_MASTER=`flintrock --config config.yaml describe spark-cluster | grep master: | awk '{print $2}'`
ssh -i flintrock-sa-east-1.pem -o StrictHostKeyChecking=no ec2-user@$IP_MASTER 'ssh -T -o StrictHostKeyChecking=no ec2-user@$(hostname) "mkdir scripts"'
scp -i flintrock-sa-east-1.pem ./scripts/* ec2-user@$IP_MASTER:~/scripts
scp -i flintrock-sa-east-1.pem ./conf/hadoop/* ec2-user@$IP_MASTER:~/hadoop/conf/
ssh -i flintrock-sa-east-1.pem ec2-user@$IP_MASTER 'chmod +x ~/scripts/*.sh'
ssh -i flintrock-sa-east-1.pem ec2-user@$IP_MASTER './hadoop/sbin/stop-all.sh'
ssh -i flintrock-sa-east-1.pem ec2-user@$IP_MASTER './hadoop/sbin/start-all.sh'
