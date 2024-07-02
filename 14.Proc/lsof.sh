#!/bin/bash

echo -e "COMMAND\tPID\tUSER\tFD\tTYPE\tNODE\tNAME"

for pid in $(ls /proc | grep -E '^[0-9]+$'); do
    if [ -d /proc/$pid ]; then
        cmd=$(cat /proc/$pid/comm)
        user=$(ps -o user= -p $pid)
        for fd in $(ls /proc/$pid/fd); do
            fd_path=$(readlink -f /proc/$pid/fd/$fd)
            type=$(ls -l /proc/$pid/fd/$fd | awk '{print $1}')
            node=$(stat -c '%i' /proc/$pid/fd/$fd)
            echo -e "${cmd}\t${pid}\t${user}\t${fd}\t${type}\t${node}\t${fd_path}"
        done
    fi
done
