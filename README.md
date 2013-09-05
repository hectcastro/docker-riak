# docker-riak

This is a [Docker](http://docker.io) project to bring up a local
[Riak](https://github.com/basho/riak) cluster. In addition, the
[Pipework](https://github.com/jpetazzo/pipework) project is used to connect
containers to each other.

## Configuration

### Install Docker and dependencies

[Install](http://www.docker.io/gettingstarted/#h_installation) Docker on
Linux, or run within a Linux virtual machine.

Then install `git`, `make`, and `sshpass`:

```bash
$ sudo apt-get install -y git curl make sshpass
```

## Running

### Clone repository

```bash
$ git clone https://github.com/hectcastro/docker-riak.git
$ cd docker-riak
$ make
$ make riak-container
```

### Launch cluster

```bash
$ make start-cluster
```

### Test cluster

```bash
$ make test-cluster
```

### Tear down cluster

```bash
$ make stop-cluster
```
