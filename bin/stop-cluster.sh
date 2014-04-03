#! /bin/bash

set -e
# set -x

for container in $(docker ps | grep "hectcastro/riak" | cut -d" " -f1);
do
  docker kill "${container}" > /dev/null 2>&1
  docker rm "${container}" > /dev/null 2>&1
done

echo "Stopped the cluster and cleared all of the running containers."
