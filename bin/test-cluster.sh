#! /bin/bash

set -e

for index in `seq 5`;
do
  echo "Testing [riak${index}]...`curl -s http://33.33.33.${index}0:8098/ping`"
done
