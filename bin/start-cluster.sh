#! /bin/bash

set -e
set -x

if sudo docker ps | grep "hectcastro/riak" >/dev/null; then
  echo ""
  echo "It looks like you already have some containers running."
  echo "Please take them down before attempting to bring up another"
  echo "cluster with the following command:"
  echo ""
  echo "  make stop-cluster"
  echo ""

  exit 1
fi

for index in `seq 5`;
do
  CONTAINER_ID=$(sudo docker run -d -i \
    -h "riak${index}" \
    -e "RIAK_NODE_NAME=33.33.33.${index}0" \
    -t "hectcastro/riak")

  sleep 1

  sudo ./bin/pipework br1 ${CONTAINER_ID} "33.33.33.${index}0"

  if [ "$index" -eq "1" ] ; then
    sudo ifconfig br1 33.33.33.254

    sleep 1
  fi

  until curl -s "http://33.33.33.${index}0:8098/ping" | grep "OK" >/dev/null;
  do
    sleep 1
  done

  if [ "$index" -gt "1" ] ; then
    sshpass -p "basho" \
      ssh -o "StrictHostKeyChecking no" root@33.33.33.${index}0 \
        riak-admin cluster join riak@33.33.33.10
  fi
done

sleep 1

sshpass -p "basho" \
  ssh -o "StrictHostKeyChecking no" root@33.33.33.10 \
    riak-admin cluster plan

read -p "Commit these cluster changes? (y/n): " RESP
if [[ $RESP =~ ^[Yy]$ ]] ; then
  sshpass -p "basho" \
    ssh -o "StrictHostKeyChecking no" root@33.33.33.10 \
      riak-admin cluster commit
else
  sshpass -p "basho" \
    ssh -o "StrictHostKeyChecking no" root@33.33.33.10 \
      riak-admin cluster clear
fi
