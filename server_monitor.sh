#!/bin/bash

clear
#rm server_monitor.log
#rm alerts.log

# Function to save logs into a file

logs() {
    echo "$(date) - $1" >> server_monitor.log
    cat server_monitor.log
    cat alerts.log
}

# Function to check disk usage and send alert if exceeds threshold

Disk_Usage() {
    echo "Inside Disk_Usage"
    disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    threshold=30

    if [ $disk_usage -gt $threshold ]; then
        logs "Disk usage is $disk_usage%, exceeds threshold of $threshold%"
        echo -e "\e[1;31mDisk usage is $disk_usage%, exceeds threshold of $threshold%. Sending alert...\e[0m" >> alerts.log
    else
        logs "Disk usage is $disk_usage%, within threshold"
    fi
}	

# Function to monitor CPU usage and send alert if exceeds threshold

Cpu_Usage() {
    echo "Inside Cpu_Usage"
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    threshold=30

    if [ $cpu_usage -gt $threshold ]; then
        logs "CPU usage is $cpu_usage%, exceeds threshold of $threshold%"
        echo -e "\e[1;32mCPU usage is $cpu_usage%, exceeds threshold of $threshold%. Sending alert...\e[0m" >> alerts.log

    else
        logs "CPU usage is $cpu_usage%, within threshold"
    fi
}

# Function to monitor memory usage and send alert if falls below threshold

Memory_Usage() {
    echo "Inside Memory_Usage"
    memory_free=$(free | awk '/Mem/{print $4}')
    total_memory=$(free | awk '/Mem/{print $2}')
    threshold=$((total_memory / 10)) # 10% free memory threshold

    if [ $memory_free -lt $threshold ]; then
        logs "Available memory is low: $memory_free KB, falls below threshold of $threshold KB"
        echo -e "\e[1;33mAvailable memory is low: $memory_free KB, falls below threshold of $threshold KB. Sending alert...\e[0m" >> alerts.log
    else
        logs "Available memory is $memory_free KB, above threshold"
    fi
}

# Function to implement log rotation

logfile_rotation() {
    
    log_file="/path/to/logfile.log"
    max_size="10M"

    if [ -f "$log_file" ]; then
        if [ $(stat -c %s "$log_file") -gt $(numfmt --from=auto "$max_size") ]; then
            logs "Rotating log file $log_file"
            mv "$log_file" "$log_file.$(date +%Y%m%d%H%M%S)"
            touch "$log_file"
            logrotate -vf /etc/logrotate.conf
        fi
    else
        logs "Log file $log_file not found"
    fi
}

# Main menu by using while loop

while true; do
    echo "Select an option:"
    echo "1. Check Disk Usage"
    echo "2. Check CPU Usage"
    echo "3. Check Memory Usage"
    echo "4. Implement Log Rotation"
    echo "5. Exit"
    
    read -p "Enter your choice: " choice
    
    case $choice in
        1)
            Disk_Usage
            ;;
        2)
            Cpu_Usage
            ;;
        3)
            Memory_Usage
            ;;
        4)
            logfile_rotation
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac
done



