#!/bin/sh
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $1
  d # delete partition
    # default, partition 3
  d # delete partition
    # default, partition 2
  d # delete partition, default, partition 3
  p # print the in-memory partition table
  w # write the partition table
EOF