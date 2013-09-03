#! /bin/bash

set -e
set -x

sudo docker ps | grep "hectcastro/riak" | awk '{ print $1 }' | xargs -r sudo docker kill
