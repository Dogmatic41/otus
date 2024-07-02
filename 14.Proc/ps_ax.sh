#!/bin/bash

echo -e "PID\tTTY\tSTAT\tTIME\tCOMMAND"

for pid in $(ls /proc | grep -E '^[0-9]+$'); do
    if [ -d /proc/$pid ]; then
        # PID
        pid=$pid
        
        # TTY
        tty=$(ls -l /proc/$pid/fd/0 | awk '{print $NF}' | sed 's/\/dev\///')
        [ -z "$tty" ] && tty="?"

        # STAT
        stat=$(cat /proc/$pid/stat | awk '{print $3}')
        
        # TIME
        utime=$(awk '{print $14}' /proc/$pid/stat)
        stime=$(awk '{print $15}' /proc/$pid/stat)
        total_time=$((utime + stime))
        time=$(printf "%02d:%02d:%02d" $((total_time/3600)) $(((total_time%3600)/60)) $((total_time%60)))
        
        # COMMAND
        cmd=$(tr -d '\0' < /proc/$pid/cmdline)
        [ -z "$cmd" ] && cmd=$(cat /proc/$pid/comm)

        echo -e "${pid}\t${tty}\t${stat}\t${time}\t${cmd}"
    fi
done
