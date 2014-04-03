# Riak
#
# VERSION       0.2.0

FROM ubuntu:precise
MAINTAINER Hector Castro hector@basho.com

# Install dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update -qq && apt-get install -y \
    logrotate \
    openssh-server

# Create run directory for sshd
RUN mkdir -p /var/run/sshd

# Install Riak
ENV RIAK_VERSION 1.4.8
ENV RIAK_SHORT_VERSION 1.4
ADD http://s3.amazonaws.com/downloads.basho.com/riak/$RIAK_SHORT_VERSION/$RIAK_VERSION/ubuntu/precise/riak_$RIAK_VERSION-1_amd64.deb /
RUN dpkg -i /riak_$RIAK_VERSION-1_amd64.deb
RUN rm /riak_$RIAK_VERSION-1_amd64.deb

# Update locale
RUN locale-gen en_US en_US.UTF-8

# Set root password
RUN echo 'root:basho' | chpasswd

# Tune Riak configuration settings for the container
RUN sed -i.bak 's/127.0.0.1/0.0.0.0/' /etc/riak/app.config && \
    sed -i.bak 's/{anti_entropy_concurrency, 2}/{anti_entropy_concurrency, 1}/' /etc/riak/app.config && \
    sed -i.bak 's/{map_js_vm_count, 8 }/{map_js_vm_count, 0 }/' /etc/riak/app.config && \
    sed -i.bak 's/{reduce_js_vm_count, 6 }/{reduce_js_vm_count, 0 }/' /etc/riak/app.config && \
    sed -i.bak 's/{hook_js_vm_count, 2 }/{hook_js_vm_count, 0 }/' /etc/riak/app.config && \
    sed -i.bak "s/##+zdbbl/+zdbbl/" /etc/riak/vm.args

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

# Make Riak's data directory a volume
VOLUME /var/lib/riak

# Open ports for ssh and Riak (HTTP)
EXPOSE 22 8098

ADD bin/boot.sh /

CMD ["/bin/bash", "/boot.sh"]
