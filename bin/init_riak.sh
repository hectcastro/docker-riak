#!/usr/bin/env bash

# If riak should be run as an runit service, simply symlink the run script to
# /etc/service/riak/run.
#
# Otherwise, exec riak here in the background.
if env | grep -q "DOCKER_RIAK_SERVICE=1"; then
  mkdir -p /etc/service/riak
  ln -s /usr/local/bin/run_riak.sh /etc/service/riak/run
else
  /usr/local/bin/run_riak.sh &
fi
