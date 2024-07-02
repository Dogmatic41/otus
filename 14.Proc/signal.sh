#!/bin/bash

trap 'echo "Received SIGINT"; exit 0' SIGINT
trap 'echo "Received SIGTERM"; exit 0' SIGTERM
trap 'echo "Received SIGHUP"' SIGHUP

echo "Running script. PID: $$"
while true; do
    sleep 1
done
