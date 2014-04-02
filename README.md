# docker-riak

This is a [Docker](http://docker.io) project to bring up a local
[Riak](https://github.com/basho/riak) cluster.

## Prerequisites

### Install Docker

Follow the [instructions on Docker's website](https://www.docker.io/gettingstarted/#h_installation)
to install Docker.

From there, ensure that your `DOCKER_HOST` environmental variable is set
correctly:

```bash
$ export DOCKER_HOST="tcp://127.0.0.1:4243"
```

### Install `sshpass`

On most UNIX operating systems, `sshpass` is included in their package
repositories:

```bash
$ sudo apt-get install sshpass
```

For Mac OS X, [Homebrew](http://brew.sh/) does not include a formula for
`sshpass`. The following [gist](https://gist.github.com/hectcastro/9939162)
includes a formula for `sshpass`:

```bash
$ brew install https://gist.githubusercontent.com/hectcastro/9939162/raw/2650be426e8c8b1a47acd7097c9d1eb41ddfc2af/sshpass.rb
```

## Running

### Clone repository and build Riak container

```bash
$ git clone https://github.com/hectcastro/docker-riak.git
$ cd docker-riak
$ make riak-container
```

### Launch cluster

```bash
$ make start-cluster
./bin/start-cluster.sh
Bringing up [riak01]...
Successfully brought up [riak01]
Bringing up [riak02] and linking it to [riak01]...
Successfully brought up [riak02]
Bringing up [riak03] and linking it to [riak01]...
Successfully brought up [riak03]
Bringing up [riak04] and linking it to [riak01]...
Successfully brought up [riak04]
Bringing up [riak05] and linking it to [riak01]...
Successfully brought up [riak05]
=============================== Staged Changes ================================
Action         Details(s)
-------------------------------------------------------------------------------
join           'riak@172.17.0.3'
join           'riak@172.17.0.4'
join           'riak@172.17.0.5'
join           'riak@172.17.0.6'
-------------------------------------------------------------------------------


NOTE: Applying these changes will result in 1 cluster transition

###############################################################################
                         After cluster transition 1/1
###############################################################################

================================= Membership ==================================
Status     Ring    Pending    Node
-------------------------------------------------------------------------------
valid     100.0%     20.3%    'riak@172.17.0.2'
valid       0.0%     20.3%    'riak@172.17.0.3'
valid       0.0%     20.3%    'riak@172.17.0.4'
valid       0.0%     20.3%    'riak@172.17.0.5'
valid       0.0%     18.8%    'riak@172.17.0.6'
-------------------------------------------------------------------------------
Valid:5 / Leaving:0 / Exiting:0 / Joining:0 / Down:0

Transfers resulting from cluster changes: 51
  13 transfers from 'riak@172.17.0.2' to 'riak@172.17.0.4'
  13 transfers from 'riak@172.17.0.2' to 'riak@172.17.0.3'
  12 transfers from 'riak@172.17.0.2' to 'riak@172.17.0.6'
  13 transfers from 'riak@172.17.0.2' to 'riak@172.17.0.5'

Commit these cluster changes? (y/n): y
Cluster changes committed
```

### Test cluster

```bash
$ make test-cluster
./bin/test-cluster.sh
TRUE All nodes agree on the ring ['riak@172.17.0.2','riak@172.17.0.3',
                                  'riak@172.17.0.4','riak@172.17.0.5',
                                  'riak@172.17.0.6']
```

### Tear down cluster

```bash
$ make stop-cluster
./bin/stop-cluster.sh
Stopped the cluster and cleared all of the running containers.
```

## Troubleshooting

Spinning up Docker containers consumes memory. If the memory allocated to your
Ubuntu [virtual] machine is not adequate, `make start-cluster` will fail with
something like:

```
runtime: panic before malloc heap initialized
fatal error: runtime: cannot allocate heap metadata
```
