#! /bin/bash

set -e
set -x

for index in `seq 5`;
do
  curl http://33.33.33.${index}0:8098/ping
done
