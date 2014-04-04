#! /bin/bash

set -e
# set -x

SEED_CONTAINER_ID=$(docker ps | egrep "riak01" | cut -d" " -f1)
SEED_HTTP_PORT=$(docker port "$SEED_CONTAINER_ID" 8098 | cut -d ":" -f2)

curl -s "http://localhost:$SEED_HTTP_PORT/stats" | python -mjson.tool
