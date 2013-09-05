#! /bin/bash

set -e

if sudo docker ps | grep "hectcastro/riak" >/dev/null; then
  sudo docker ps | grep "hectcastro/riak" | awk '{ print $1 }' | xargs -r sudo docker kill >/dev/null
  echo "Stopped the cluster and cleared all of the running containers."
fi
