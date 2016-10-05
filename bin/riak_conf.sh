#!/usr/bin/env bash

IP_ADDRESS=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

# Ensure correct ownership and permissions on volumes
chown riak:riak /var/lib/riak /var/log/riak
chmod 755 /var/lib/riak /var/log/riak

# Open file descriptor limit
ulimit -n 65536

# Ensure the Erlang node name is set correctly
sed -i.bak "s/riak@127.0.0.1/riak@${IP_ADDRESS}/" /etc/riak/riak.conf

# Ensure the desired Riak backend is set correctly
sed -i.bak "s/storage_backend = \(.*\)/storage_backend = ${DOCKER_RIAK_BACKEND}/" /etc/riak/riak.conf

# Ensure the strong consistency property is set correctly
sed -i.bak "s/## strong_consistency = \(.*\)/strong_consistency = ${DOCKER_RIAK_STRONG_CONSISTENCY}/" /etc/riak/riak.conf

# Ensure the search property is set correctly
sed -i.bak "s/search = \(.*\)/search = ${DOCKER_RIAK_SEARCH}/" /etc/riak/riak.conf
