#! /bin/bash

set -e

if env | grep -q "DOCKER_RIAK_DEBUG"; then
  set -x
fi

SEED_CONTAINER_ID=$(docker ps | egrep "riak01[^0-9]" | cut -d" " -f1)
SEED_HTTP_PORT=$(docker port "${SEED_CONTAINER_ID}" 8098 | cut -d ":" -f2)

curl -s "http://localhost:${SEED_HTTP_PORT}/stats" | python -mjson.tool
