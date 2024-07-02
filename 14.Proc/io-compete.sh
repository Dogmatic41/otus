#!/bin/bash

dd if=/dev/zero of=/tmp/testfile1 bs=1M count=1024 oflag=direct &
pid1=$!
ionice -c2 -n0 -p$pid1

dd if=/dev/zero of=/tmp/testfile2 bs=1M count=1024 oflag=direct &
pid2=$!
ionice -c2 -n7 -p$pid2

wait $pid1
echo "Process 1 finished"

wait $pid2
echo "Process 2 finished"
