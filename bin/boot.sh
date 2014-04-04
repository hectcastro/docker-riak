#! /bin/bash

set -e
# set -x

# Change owner and permissions on volumes
chown riak:riak /var/lib/riak /var/log/riak
chmod 755 /var/lib/riak /var/log/riak

IP_ADDRESS=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

# Start Riak and wait for KV
sed -i.bak "s/127.0.0.1/$IP_ADDRESS/" /etc/riak/vm.args
service riak start
riak-admin wait-for-service riak_kv "riak@$IP_ADDRESS"

# Join node to the cluster
if env | grep -q "SEED_PORT_22_TCP_ADDR"; then
  riak-admin cluster join "riak@$SEED_PORT_22_TCP_ADDR"
  sleep 3
fi

# Are we the last node to join?
if riak-admin member-status | grep "joining" | wc -l | grep -q 4; then
  riak-admin cluster plan && riak-admin cluster commit
fi

while true; do sleep 1; done
