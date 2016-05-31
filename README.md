# docker-riak [![Build Status](https://secure.travis-ci.org/hectcastro/docker-riak.png?branch=develop)](http://travis-ci.org/hectcastro/docker-riak)

This is a [Docker](http://docker.io) project to bring up a local
[Riak](https://github.com/basho/riak) cluster.

## Prerequisites

### Install Docker

Follow the [instructions on Docker's website](https://www.docker.io/gettingstarted/#h_installation)
to install Docker.

From there, ensure that your `DOCKER_HOST` environmental variable is set
correctly:

```bash
$ export DOCKER_HOST="tcp://127.0.0.1:2375"
```

**Note:** If you're using
[boot2docker](https://github.com/boot2docker/boot2docker) ensure that you
forward the virtual machine port range (`49000-49900`). If you want to set
`DOCKER_RIAK_BASE_HTTP_PORT`, ensure that you forward that port range instead:

```bash
$ for i in {49000..49900}; do
 VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port$i,tcp,,$i,,$i";
 VBoxManage modifyvm "boot2docker-vm" --natpf1 "udp-port$i,udp,,$i,,$i";
done
```

### `sysctl`

In order to tune the Docker host housing Riak containers, consider applying
the following `sysctl` settings:

```
vm.swappiness = 0
net.ipv4.tcp_max_syn_backlog = 40000
net.core.somaxconn = 40000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_moderate_rcvbuf = 1
```

## Running

### Clone repository and build Riak image

```bash
$ git clone https://github.com/hectcastro/docker-riak.git
$ cd docker-riak
$ make build
```

### Environmental variables

- `DOCKER_RIAK_CLUSTER_SIZE` – The number of nodes in your Riak cluster
  (default: `5`)
- `DOCKER_RIAK_AUTOMATIC_CLUSTERING` – A flag to automatically cluster Riak
  (default: `false`)
- `DOCKER_RIAK_DEBUG` – A flag to `set -x` on the cluster management scripts
  (default: `false`)
- `DOCKER_RIAK_BASE_HTTP_PORT` - A flag to use fixed port assignment. If set,
  manually forward port `DOCKER_RIAK_BASE_HTTP_PORT + $index` to `8098`
  (Riak's HTTP port) and forward
  `DOCKER_RIAK_BASE_HTTP_PORT + $index + DOCKER_RIAK_PROTO_BUF_PORT_OFFSET`
  to `8087` (Riak's Protocol Buffers port).
- `DOCKER_RIAK_PROTO_BUF_PORT_OFFSET` - Optional port offset (default: `100`)
- `DOCKER_RIAK_BACKEND` - Optional Riak backend to use (default: `bitcask`)
- `DOCKER_RIAK_STRONG_CONSISTENCY` - Enables strong consistency subsystem (values: `on` or `off`, default: `off`)

### Launch cluster

```bash
$ DOCKER_RIAK_AUTOMATIC_CLUSTERING=1 DOCKER_RIAK_CLUSTER_SIZE=5 DOCKER_RIAK_BACKEND=leveldb make start-cluster
./bin/start-cluster.sh

Bringing up cluster nodes:

  Successfully brought up [riak01]
  Successfully brought up [riak02]
  Successfully brought up [riak03]
  Successfully brought up [riak04]
  Successfully brought up [riak05]

Please wait approximately 30 seconds for the cluster to stabilize.
```

## Testing

From outside the container, we can interact with the
[HTTP](http://docs.basho.com/riak/latest/dev/references/http/) or
[Protocol Buffers](http://docs.basho.com/riak/latest/dev/references/protocol-buffers/)
interfaces.

### HTTP

The HTTP interface has an endpoint called `/stats` that emits Riak
statistics. The `test-cluster` `Makefile` target hits a random container's
`/stats` endpoint and pretty-prints its output to the console.

The most interesting attributes for testing cluster membership are
`ring_members`:

```bash
$ make test-cluster | egrep -A6 "ring_members"
    "ring_members": [
        "riak@172.17.0.2",
        "riak@172.17.0.3",
        "riak@172.17.0.4",
        "riak@172.17.0.5",
        "riak@172.17.0.6"
    ],
```

And `ring_ownership`:

```bash
$ make test-cluster | egrep "ring_ownership"
    "ring_ownership": "[{'riak@172.17.0.20',3},\n {'riak@172.17.0.10',4},\n {'riak@172.17.0.21',3},\n {'riak@172.17.0.11',4},\n {'riak@172.17.0.2',3},\n {'riak@172.17.0.12',4},\n {'riak@172.17.0.3',3},\n {'riak@172.17.0.13',4},\n {'riak@172.17.0.4',3},\n {'riak@172.17.0.14',3},\n {'riak@172.17.0.5',3},\n {'riak@172.17.0.15',3},\n {'riak@172.17.0.6',3},\n {'riak@172.17.0.16',3},\n {'riak@172.17.0.7',3},\n {'riak@172.17.0.17',3},\n {'riak@172.17.0.8',3},\n {'riak@172.17.0.18',3},\n {'riak@172.17.0.9',3},\n {'riak@172.17.0.19',3}]",
```

Together, these attributes let us know that this particular Riak node knows
about all of the other Riak instances.

### SSH

The [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker)
image has the ability to enable an __insecure__ key for conveniently logging
into a container via SSH. It is enabled in the `Dockerfile` by default here:

```docker
RUN /usr/sbin/enable_insecure_key
```

In order to login to the container via SSH using the __insecure__ key, follow
the steps below.

Use `docker inspect` to determine the container IP address:

```bash
$ docker inspect $CONTAINER_ID | grep IPAddress
        "IPAddress": "172.17.0.2",
```

Download the insecure key, alter its permissions, and use it to SSH into the
container via its IP address:

```bash
$ curl -o insecure_key -fSL https://github.com/phusion/baseimage-docker/raw/master/image/services/sshd/keys/insecure_key
$ chmod 600 insecure_key
$ ssh -i insecure_key root@172.17.0.2
```

**Note:** If you're using
[boot2docker](https://github.com/boot2docker/boot2docker), ensure that you're
issuing the SSH command from within the virtual machine running `boot2docker`.

## Destroying

```bash
$ make stop-cluster
./bin/stop-cluster.sh
Stopped the cluster and cleared all of the running containers.
```
