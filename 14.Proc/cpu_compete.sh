#!/bin/bash

stress --cpu 2 --timeout 30 &
pid1=$!
renice -n -10 -p $pid1

stress --cpu 2 --timeout 30 &
pid2=$!
renice -n 10 -p $pid2

wait $pid1
echo "Process 1 finished"

wait $pid2
echo "Process 2 finished"
