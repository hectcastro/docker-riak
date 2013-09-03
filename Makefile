all: pipework

pipework:
	curl -s https://raw.github.com/jpetazzo/pipework/master/pipework > ./bin/pipework
	chmod u+x ./bin/pipework
	sudo sed -i.bak 's/\#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
	sudo sysctl -p /etc/sysctl.conf
	sudo /etc/init.d/procps restart >/dev/null

riak:
	sudo docker build -t "hectcastro/riak" .

start-cluster:
	./bin/start-cluster.sh

test-cluster:
	./bin/test-cluster.sh

stop-cluster:
	./bin/stop-cluster.sh
