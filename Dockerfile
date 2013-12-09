# Riak
#
# VERSION       0.1.0

# Use the Ubuntu base image provided by dotCloud
FROM ubuntu:latest
MAINTAINER Hector Castro hector@basho.com

# Update the APT cache
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

# Install and setup project dependencies
RUN apt-get install -y curl lsb-release supervisor openssh-server

RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor

RUN locale-gen en_US en_US.UTF-8

ADD ./etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN echo 'root:basho' | chpasswd

# Add Basho's APT repository
ADD basho.apt.key /tmp/basho.apt.key
RUN apt-key add /tmp/basho.apt.key
RUN rm /tmp/basho.apt.key
RUN echo "deb http://apt.basho.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/basho.list
RUN apt-get update

# Install Riak and prepare it to run
RUN apt-get install -y riak
RUN sed -i.bak 's/127.0.0.1/0.0.0.0/' /etc/riak/app.config
RUN echo "sed -i.bak \"s/127.0.0.1/\${RIAK_NODE_NAME}/\" /etc/riak/vm.args" > /etc/default/riak
RUN sed -i.bak 's/{anti_entropy_concurrency, 2}/{anti_entropy_concurrency, 1}/' /etc/riak/app.config
RUN sed -i.bak 's/{map_js_vm_count, 8 }/{map_js_vm_count, 0 }/' /etc/riak/app.config
RUN sed -i.bak 's/{reduce_js_vm_count, 6 }/{reduce_js_vm_count, 0 }/' /etc/riak/app.config
RUN sed -i.bak 's/{hook_js_vm_count, 2 }/{hook_js_vm_count, 0 }/' /etc/riak/app.config
RUN sed -i.bak "s/##+zdbbl/+zdbbl/" /etc/riak/vm.args

# ulimits
RUN echo "ulimit -n 4096" >> /etc/default/riak

# sysctl
RUN echo "vm.swappiness = 0" > /etc/sysctl.d/riak.conf && \
    echo "net.ipv4.tcp_max_syn_backlog = 40000" >> /etc/sysctl.d/riak.conf && \
    echo "net.core.somaxconn = 40000" >> /etc/sysctl.d/riak.conf && \
    echo "net.ipv4.tcp_sack = 1" >> /etc/sysctl.d/riak.conf && \
    echo "net.ipv4.tcp_window_scaling = 1" >> /etc/sysctl.d/riak.conf && \
    echo "net.ipv4.tcp_fin_timeout = 15" >> /etc/sysctl.d/riak.conf && \
    echo "net.ipv4.tcp_keepalive_intvl = 30" >> /etc/sysctl.d/riak.conf && \
    echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.d/riak.conf && \
    echo "net.ipv4.tcp_moderate_rcvbuf = 1" >> /etc/sysctl.d/riak.conf && \
    sysctl -e -p /etc/sysctl.d/riak.conf

# Open ports for ssh and Riak (HTTP)
EXPOSE 22 8098

ADD bin/boot.sh /

CMD ["/bin/bash", "/boot.sh"]
