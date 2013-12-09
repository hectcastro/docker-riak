#! /bin/bash

set -e
# set -x

if docker ps | grep "hectcastro/riak" >/dev/null; then
  echo ""
  echo "It looks like you already have some containers running."
  echo "Please take them down before attempting to bring up another"
  echo "cluster with the following command:"
  echo ""
  echo "  make stop-cluster"
  echo ""

  exit 1
fi

for index in `seq 1 5`;
do
  if [ "$index" -gt "1" ] ; then
    echo "Bringing up [riak0${index}] and linking it to [riak01]..."
    docker run -P --name riak0${index} --link riak01:seed -d hectcastro/riak > /dev/null 2>&1
  else
    echo "Bringing up [riak0${index}]..."
    docker run -P --name riak0${index} -d hectcastro/riak > /dev/null 2>&1
  fi

  CONTAINER_ID=$(docker ps | egrep "riak0${index}[^/]" | cut -d" " -f1)
  PORT=$(docker inspect $CONTAINER_ID | grep -A13 "PortBindings" | grep -A5 "8098/tcp" | grep "HostPort" | cut -d'"' -f 4 | tr -d "\n")

  until curl -s "http://localhost:$PORT/ping" | grep "OK" >/dev/null;
  do
    sleep 3
  done

  echo "Successfully brought up [riak0${index}]"
done

sleep 10

SEED_CONTAINER_ID=$(docker ps | egrep "riak01" | cut -d" " -f1)
SEED_SSH_PORT=$(docker inspect $SEED_CONTAINER_ID | grep -A13 "PortBindings" | grep -A5 "22/tcp" | grep "HostPort" | cut -d'"' -f 4 | tr -d "\n")

sshpass -p "basho" \
  ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" -p $SEED_SSH_PORT root@localhost \
    riak-admin cluster plan

read -p "Commit these cluster changes? (y/n): " RESP
if [[ $RESP =~ ^[Yy]$ ]] ; then
  sshpass -p "basho" \
    ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" -p $SEED_SSH_PORT root@localhost \
      riak-admin cluster commit
else
  sshpass -p "basho" \
    ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" -p $SEED_SSH_PORT root@localhost \
      riak-admin cluster clear
fi
