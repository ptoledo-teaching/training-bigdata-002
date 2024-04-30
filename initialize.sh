source credentials/aws/credentials.sh
IP_MASTER=`flintrock --config config/flintrock/config.yaml describe spark-cluster | grep master: | awk '{print $2}'`
ssh -i keys/flintrock-sa-east-1.pem -o StrictHostKeyChecking=no ec2-user@$IP_MASTER 'ssh -T -o StrictHostKeyChecking=no ec2-user@$(hostname) "mkdir scripts"'
scp -i keys/flintrock-sa-east-1.pem scripts/master/* ec2-user@$IP_MASTER:~/scripts
ssh -i keys/flintrock-sa-east-1.pem ec2-user@$IP_MASTER 'chmod +x ~/scripts/*.sh'
scp -i keys/flintrock-sa-east-1.pem config/hadoop/* ec2-user@$IP_MASTER:~/hadoop/conf/
ssh -i keys/flintrock-sa-east-1.pem ec2-user@$IP_MASTER './hadoop/sbin/stop-dfs.sh && ./hadoop/sbin/start-dfs.sh'