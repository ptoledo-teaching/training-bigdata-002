#!/bin/bash

IP_FILE=~/spark/conf/slaves
if [ ! -f "$IP_FILE" ]; then
    echo "Error: IP file '$IP_FILE' not found."
    exit 1
fi
IPS=`echo $(hostname); cat $IP_FILE`

if [ -z "$1" ]; then
    timeout=5
else
    timeout="$1"
fi

timeout_ssh=$(echo "$timeout - 1" | bc)
if [ "$timeout_ssh" -lt 1 ]; then
    timeout_ssh=1
fi
while true; do
    timer=$(date +%s.%N)
    for IP in $IPS; do
        (
            rm -f /tmp/$IP.usage
            timeout $timeout_ssh ssh $IP << 'EOF' > /tmp/$IP.usage 2>/dev/null
            total_mem=$(free -m | awk 'NR==2{print $2}')
            mem_used=$(free -m | awk 'NR==2{print $3}')
            mem_usage=$(echo "scale=2; $mem_used / $total_mem * 100" | bc | awk -F. '{print $1}')
            cpu_usage=$(top -bn1 | grep '%Cpu(s):' | sed 's/.*,\s*\([0-9.]*\)%* id.*/\1/' | awk '{print 100 - $1}')
            printf "CPU %3.0f%% MEM %3.0f%%\n" "$cpu_usage" "$mem_usage"
EOF
        ) &
    done
    wait
    echo -n "" > /tmp/usage.txt
    FIRST=true
    for IP in $IPS; do
        if [ "$FIRST" = true ]; then
            FIRST=false
            echo -n "| " >> /tmp/usage.txt
        else
            echo -n " | " >> /tmp/usage.txt
        fi
        usage=$(cat /tmp/$IP.usage | tr -d '\n')
        if [ -z "$usage" ]; then
            echo -n "                 " >> /tmp/usage.txt
        else
            cpu_message="$(echo "$usage" | awk -F' MEM' '{print $1}')"
            cpu_usage=$(echo $usage | awk '{print $2}' | tr -d '%')
            mem_message="$(echo "$usage" | awk -F'% ' '{print $2}')"
            mem_usage=$(echo $usage | awk '{print $4}' | tr -d '%')
            if (( cpu_usage > 90 )); then
                echo -ne "\e[1;31m$cpu_message\e[0m " >> /tmp/usage.txt
                elif (( cpu_usage > 50 )); then
                echo -ne "\e[1;93m$cpu_message\e[0m " >> /tmp/usage.txt
                elif (( cpu_usage > 10 )); then
                echo -ne "\e[1;32m$cpu_message\e[0m " >> /tmp/usage.txt
            else
                echo -n "$cpu_message " >> /tmp/usage.txt
            fi
            if (( cpu_umem_usageage > 75 )); then
                echo -ne "\e[1;31m$mem_message\e[0m" >> /tmp/usage.txt
                elif (( mem_usage > 50 )); then
                echo -ne "\e[1;93m$mem_message\e[0m" >> /tmp/usage.txt
                elif (( mem_usage > 20 )); then
                echo -ne "\e[1;32m$mem_message\e[0m" >> /tmp/usage.txt
            else
                echo -n "$mem_message" >> /tmp/usage.txt
            fi
        fi
    done
    echo " |" >> /tmp/usage.txt
    cat /tmp/usage.txt
    timer=$(echo "$timeout - $(date +%s.%N) + $timer" | bc)
    if (( $(echo "$timer > 0" | bc -l) )); then
        sleep $timer
    fi
done
