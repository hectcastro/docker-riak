#!/usr/bin/env bash

function start_exited_riak_containers {
  containers=`docker ps -a -f "status=exited" --format "table {{.Names}}\t{{.ID}}\t{{.Image}}" | grep "hectcastro/riak" || :`
  if [[ ! -z $containers ]]; then
    echo "Bringing up stopped docker instances."
    echo "$containers" | sort -V | while read -r container; 
    do
      CONTAINER_ID=`echo $container | awk '{print $2}'`
      CONTAINER_NAME=`echo $container | awk '{print $1}'`
      echo -n "Starting ${CONTAINER_NAME}..."
      docker start ${CONTAINER_ID} > /dev/null 2>&1  
      echo " Completed"
    done

    echo
    echo "Please wait approximately 30 seconds for the cluster to stabilize."
    echo
  fi
}

function start_new_riak_cluter {
  
  # The default allows Docker to forward arbitrary ports on the VM for the Riak
  # containers. Ports used by default are usually in the 49xx range.

  publish_http_port="8098"
  publish_pb_port="8087"

  # If DOCKER_RIAK_BASE_HTTP_PORT is set, port number
  # $DOCKER_RIAK_BASE_HTTP_PORT + $index gets forwarded to 8098 and
  # $DOCKER_RIAK_BASE_HTTP_PORT + $index + $DOCKER_RIAK_PROTO_BUF_PORT_OFFSET
  # gets forwarded to 8087. DOCKER_RIAK_PROTO_BUF_PORT_OFFSET is optional and
  # defaults to 100.

  DOCKER_RIAK_PROTO_BUF_PORT_OFFSET=${DOCKER_RIAK_PROTO_BUF_PORT_OFFSET:-100}
  
  echo
  echo "Bringing up cluster nodes:"
  echo

  for index in $(seq "1" "${DOCKER_RIAK_CLUSTER_SIZE}");
  do
    index=$(printf "%.2d" "$index")
    if [[ ! -z $DOCKER_RIAK_BASE_HTTP_PORT ]] ; then
      final_http_port=$((DOCKER_RIAK_BASE_HTTP_PORT + index))
      final_pb_port=$((DOCKER_RIAK_BASE_HTTP_PORT + index + DOCKER_RIAK_PROTO_BUF_PORT_OFFSET))
      publish_http_port="${final_http_port}:8098"
      publish_pb_port="${final_pb_port}:8087"
    fi

    if [ "${index}" -gt "1" ] ; then
      docker run -e "DOCKER_RIAK_CLUSTER_SIZE=${DOCKER_RIAK_CLUSTER_SIZE}" \
                 -e "DOCKER_RIAK_AUTOMATIC_CLUSTERING=${DOCKER_RIAK_AUTOMATIC_CLUSTERING}" \
                 -e "DOCKER_RIAK_BACKEND=${DOCKER_RIAK_BACKEND}" \
                 -e "DOCKER_RIAK_STRONG_CONSISTENCY=${DOCKER_RIAK_STRONG_CONSISTENCY}" \
                 -p $publish_http_port \
                 -p $publish_pb_port \
                 --link "riak01:seed" \
                 --name "riak${index}" \
                 -d hectcastro/riak > /dev/null 2>&1
    else
      docker run -e "DOCKER_RIAK_CLUSTER_SIZE=${DOCKER_RIAK_CLUSTER_SIZE}" \
                 -e "DOCKER_RIAK_AUTOMATIC_CLUSTERING=${DOCKER_RIAK_AUTOMATIC_CLUSTERING}" \
                 -e "DOCKER_RIAK_BACKEND=${DOCKER_RIAK_BACKEND}" \
                 -e "DOCKER_RIAK_STRONG_CONSISTENCY=${DOCKER_RIAK_STRONG_CONSISTENCY}" \
                 -p $publish_http_port \
                 -p $publish_pb_port \
                 --name "riak${index}" \
                 -d hectcastro/riak > /dev/null 2>&1
    fi
    echo -n "Starting riak${index}..."

    CONTAINER_ID=$(docker ps | grep "riak${index}" | cut -d" " -f1)
    CONTAINER_PORT=$(docker port "${CONTAINER_ID}" 8098 | cut -d ":" -f2)

    until curl -m 1 -s "http://${CLEAN_DOCKER_HOST}:${CONTAINER_PORT}/ping" | grep "OK" > /dev/null 2>&1;
    do
      echo -n "."
      sleep 3
    done

    echo " Completed"
  done

  echo
  echo "Please wait approximately 30 seconds for the cluster to stabilize."
  echo
}

set -e

if env | grep -q "DOCKER_RIAK_DEBUG"; then
  set -x
fi

CLEAN_DOCKER_HOST="localhost"

if [ "${DOCKER_HOST}" ]; then
  if [[ "${DOCKER_HOST}" == unix://* ]]; then
    CLEAN_DOCKER_HOST="localhost"
  else
    CLEAN_DOCKER_HOST=$(echo "${DOCKER_HOST}" | cut -d'/' -f3 | cut -d':' -f1)
  fi
fi

DOCKER_RIAK_CLUSTER_SIZE=${DOCKER_RIAK_CLUSTER_SIZE:-5}
DOCKER_RIAK_BACKEND=${DOCKER_RIAK_BACKEND:-bitcask}
DOCKER_RIAK_STRONG_CONSISTENCY=${DOCKER_RIAK_STRONG_CONSISTENCY:-off}

if docker ps -a | grep "hectcastro/riak" >/dev/null; then
  echo ""
  echo "It looks like you already have some Riak containers."
  echo "If you want to start a new Riak cluster then please"
  echo "remove them first with the following command:"
  echo ""
  echo "  make remove-cluster"
  echo ""
  start_exited_riak_containers
else
  start_new_riak_cluter
fi
