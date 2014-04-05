#! /bin/bash

set -e

if env | grep -q "DOCKER_RIAK_DEBUG"; then
  set -x
fi

for container in $(docker ps | grep "hectcastro/riak" | cut -d" " -f1);
do
  docker rm -f "${container}" > /dev/null 2>&1
done

echo "Stopped the cluster and cleared all of the running containers."
