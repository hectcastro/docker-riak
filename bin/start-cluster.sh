#! /bin/bash

set -e
set -x

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

read -p "Commit these cluster changes? " RESP
if [[ $RESP =~ ^[Yy]$ ]] ; then
  sshpass -p "basho" \
    ssh -o "StrictHostKeyChecking no" root@33.33.33.10 \
      riak-admin cluster commit
else
  sshpass -p "basho" \
    ssh -o "StrictHostKeyChecking no" root@33.33.33.10 \
      riak-admin cluster clear
fi
