# docker-riak

This is a [Docker](http://docker.io) project to bring up a local
[Riak](https://github.com/basho/riak) cluster. In addition, the
[Pipework](https://github.com/jpetazzo/pipework) project is used to connect
containers to each other.

## Installation

### Install Docker

If you're running Ubuntu, use the instructions for [installing Docker on
Linux](http://docs.docker.io/en/latest/installation/ubuntulinux/).

If you're not on a Ubuntu host, use [Vagrant](http://www.vagrantup.com) to
spin up a [Ubuntu virtual machine with Docker
installed](http://docs.docker.io/en/latest/installation/vagrant/).

Launching the Vagrant virtual machine installs VirtualBox extensions that
require a reboot to take effect. I typically bring it up using the following
sequence of commands:

```bash
$ vagrant up && sleep 120 && vagrant reload
$ vagrant ssh
```

## Install dependencies

Once you're on a Ubuntu machine, install the following dependencies:

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

## Troubleshooting

Spinning up Docker containers consumes memory. If the memory allocated to your
Ubuntu [virtual] machine is not adaquate,  `make start-cluster` will fail with
something like:

```
runtime: panic before malloc heap initialized
fatal error: runtime: cannot allocate heap metadata
```
