#! /bin/bash

set -e
# set -x

SEED_CONTAINER_ID=$(docker ps | egrep "riak01" | cut -d" " -f1)
SEED_SSH_PORT=$(docker inspect "$SEED_CONTAINER_ID" | grep -A13 "PortBindings" | grep -A5 "22/tcp" | grep "HostPort" | cut -d'"' -f 4 | tr -d "\n")

sshpass -p "basho" \
  ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" -p "$SEED_SSH_PORT" root@localhost \
    riak-admin member-status
