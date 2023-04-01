#!/bin/sh

# suppress output of ping if not reachable
if /bin/busybox ping $@ > /dev/null 2>&1;
then
    echo "alive"
fi