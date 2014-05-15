## 0.4.1

* Change `localhost` references to `127.0.0.1`.

## 0.4.0

* Remove `sysctl` specific settings from `Dockerfile`.

## 0.3.2

* Add better detection of an invalid cluster start state

## 0.3.1

* Add support for ShellCheck via Travis CI.

## 0.3.0

* Use [phusion/baseimage](https://github.com/phusion/baseimage-docker) as the
  base image.
* Add ability to automatically cluster nodes via
  `DOCKER_RIAK_AUTOMATIC_CLUSTERING`.
* Add ability to specify cluster size via `DOCKER_RIAK_CLUSTER_SIZE`.
* Add ability to debug cluster management scripts with `DOCKER_RIAK_DEBUG`.

## 0.2.0

* Replace Pipework with Docker 0.6.5+ container linking.
* Replace `supervisord` with a Bash script.
* Add Riak and kernel tuning.
* Utilize `DOCKER_HOST` over `sudo`.
* Install Riak via direct package download.
* Use Ubuntu 12.04 as the base image.

## 0.1.2

* Add gateway to IP address added to Pipework.

## 0.1.1

* Add netmask to IP address added to Pipework.

## 0.1.0

* Initial release.
