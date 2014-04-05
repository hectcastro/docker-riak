#! /bin/bash

set -e

if env | grep -q "DOCKER_RIAK_DEBUG"; then
  set -x
fi

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

echo
echo "Bringing up cluster nodes:"
echo

for index in $(seq 1 5);
do
  if [ "$index" -gt "1" ] ; then
    docker run -P --name "riak0${index}" --link riak01:seed -d hectcastro/riak > /dev/null 2>&1
  else
    docker run -P --name "riak0${index}" -d hectcastro/riak > /dev/null 2>&1
  fi

  CONTAINER_ID=$(docker ps | egrep "riak0${index}[^/]" | cut -d" " -f1)
  CONTAINER_PORT=$(docker port "${CONTAINER_ID}" 8098 | cut -d ":" -f2)

  until curl -s "http://localhost:${CONTAINER_PORT}/ping" | grep "OK" >/dev/null;
  do
    sleep 1
  done

  echo "  Successfully brought up [riak0${index}]"
done

echo
echo "Please wait approximately 30 seconds for the cluster to stabilize."
echo
