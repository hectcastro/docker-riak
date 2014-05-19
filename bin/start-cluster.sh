#! /bin/bash

set -e

if env | grep -q "DOCKER_RIAK_DEBUG"; then
  set -x
fi

DOCKER_RIAK_CLUSTER_SIZE=${DOCKER_RIAK_CLUSTER_SIZE:-5}

if docker ps -a | grep "hectcastro/riak" >/dev/null; then
  echo ""
  echo "It looks like you already have some Riak containers running."
  echo "Please take them down before attempting to bring up another"
  echo "cluster with the following command:"
  echo ""
  echo "  make stop-cluster"
  echo ""

  exit 1
fi

echo
echo "Bringing up cluster nodes:"
echo

# The default port config is -P, which means that docker with assign 
# arbitrary ports for riak to use.  These are usually in the 49xxx range.
port_config="-P"

# if DOCKER_RIAK_BASE_HTTP_PORT is set, then we will manually forward
# port number $DOCKER_RIAK_BASE_HTTP_PORT + $index to 8098
# and forward $DOCKER_RIAK_BASE_HTTP_PORT + $index + $DOCKER_RIAK_PROTO_BUF_PORT_OFFSET to 8087
# DOCKER_RIAK_PROTO_BUF_PORT_OFFSET is optional and defaults to 100

if [ -z "$DOCKER_RIAK_PROTO_BUF_PORT_OFFSET" ] ; then 
    pb_port_offset="100"
else
    pb_port_offset="$DOCKER_RIAK_PROTO_BUF_PORT_OFFSET"
fi

for index in $(seq -f "%02g" "1" "${DOCKER_RIAK_CLUSTER_SIZE}");
do
  if [[ ! -z $DOCKER_RIAK_BASE_HTTP_PORT ]] ; then 
    final_port=$(($DOCKER_RIAK_BASE_HTTP_PORT + $index))
    final_pb_port=$(($DOCKER_RIAK_BASE_HTTP_PORT + $index + $pb_port_offset))
    port_config="-p ${final_port}:8098 -p ${final_pb_port}:8087"
  fi

  if [ "${index}" -gt "1" ] ; then
    docker run -e "DOCKER_RIAK_CLUSTER_SIZE=${DOCKER_RIAK_CLUSTER_SIZE}" \
               -e "DOCKER_RIAK_AUTOMATIC_CLUSTERING=${DOCKER_RIAK_AUTOMATIC_CLUSTERING}" \
               $port_config \
               --link "riak01:seed" \
               --name "riak${index}" \
               -d hectcastro/riak > /dev/null 2>&1
  else
    docker run -e "DOCKER_RIAK_CLUSTER_SIZE=${DOCKER_RIAK_CLUSTER_SIZE}" \
               -e "DOCKER_RIAK_AUTOMATIC_CLUSTERING=${DOCKER_RIAK_AUTOMATIC_CLUSTERING}" \
               $port_config \
               --name "riak${index}" \
               -d hectcastro/riak > /dev/null 2>&1
  fi

  CONTAINER_ID=$(docker ps | egrep "riak${index}[^/]" | cut -d" " -f1)
  CONTAINER_PORT=$(docker port "${CONTAINER_ID}" 8098 | cut -d ":" -f2)

  until curl -s "http://127.0.0.1:${CONTAINER_PORT}/ping" | grep "OK" > /dev/null 2>&1;
  do
    sleep 3
  done

  echo "  Successfully brought up [riak${index}]"
done

echo
echo "Please wait approximately 30 seconds for the cluster to stabilize."
echo
