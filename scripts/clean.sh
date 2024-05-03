#!/bin/bash
for ip in $(cat ~/spark/conf/slaves); do
    from=`ssh ec2-user@$ip 'df | grep /dev/nvme0' | awk '{print $5}'`
    ssh ec2-user@$ip 'rm -rf ~/spark/work/*/*/*.jar'
    to=`ssh ec2-user@$ip 'df | grep /dev/nvme0' | awk '{print $5}'`
    echo "Cleaning up $ip: from $from to $to"
done