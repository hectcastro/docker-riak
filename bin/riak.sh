#! /bin/sh

IP_ADDRESS=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

# Ensure correct ownership and permissions on volumes
chown riak:riak /var/lib/riak /var/log/riak
chmod 755 /var/lib/riak /var/log/riak

# Open file descriptor limit
ulimit -n 4096

# Ensure the Erlang node name is set correctly
sed -i.bak "s/127.0.0.1/${IP_ADDRESS}/" /etc/riak/vm.args

if env | grep -q "DOCKER_RIAK_INET_DIST_MIN" && ! egrep -q "inet_dist_listen_min" /etc/riak/vm.args; then
  echo "-kernel inet_dist_listen_min ${DOCKER_RIAK_INET_DIST_MIN}" >> /etc/riak/vm.args
  echo "-kernel inet_dist_listen_max ${DOCKER_RIAK_INET_DIST_MAX}" >> /etc/riak/vm.args
fi

# Start Riak
exec /sbin/setuser riak "$(ls -d /usr/lib/riak/erts*)/bin/run_erl" "/tmp/riak" \
   "/var/log/riak" "exec /usr/sbin/riak console"
