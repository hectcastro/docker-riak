.PHONY: all riak-container start-cluster test-cluster stop-cluster

all: stop-cluster riak-container start-cluster

riak-container:
	docker build -t "hectcastro/riak" .

start-cluster:
	./bin/start-cluster.sh

test-cluster:
	./bin/test-cluster.sh

stop-cluster:
	./bin/stop-cluster.sh
