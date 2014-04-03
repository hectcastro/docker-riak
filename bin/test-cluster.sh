#! /bin/bash

set -e
# set -x

SEED_CONTAINER_ID=$(docker ps | egrep "riak01" | cut -d" " -f1)
SEED_SSH_PORT=$(docker port "$SEED_CONTAINER_ID" 22 | cut -d ":" -f2)

sshpass -p "basho" \
  ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" -p "$SEED_SSH_PORT" root@localhost \
    riak-admin member-status
