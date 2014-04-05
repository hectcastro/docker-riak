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

**Note:** If you're using [boot2docker](https://github.com/boot2docker/boot2docker)
ensure that you forward the virtual machine port range (49000-49900). This
will allow you to interact with the containers as if they were running
locally:

```bash
$ for i in {49000..49900}; do
 VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port$i,tcp,,$i,,$i";
 VBoxManage modifyvm "boot2docker-vm" --natpf1 "udp-port$i,udp,,$i,,$i";
done
```

## Running

### Clone repository and build Riak container

```bash
$ git clone https://github.com/hectcastro/docker-riak.git
$ cd docker-riak
$ make riak-container
```

### Environmental variables

- `DOCKER_RIAK_CLUSTER_SIZE` – The number of nodes in your Riak cluster
  (default: `5`)
- `DOCKER_RIAK_DEBUG` – A flag to `set -x` on the cluster management scripts
  (default: `false`).

### Launch cluster

```bash
$ DOCKER_RIAK_CLUSTER_SIZE=5 make start-cluster
./bin/start-cluster.sh

Bringing up cluster nodes:

  Successfully brought up [riak01]
  Successfully brought up [riak02]
  Successfully brought up [riak03]
  Successfully brought up [riak04]
  Successfully brought up [riak05]

Please wait approximately 30 seconds for the cluster to stabilize.
```

### Test cluster

```bash
$ make test-cluster
./bin/test-cluster.sh
{
    "basho_stats_version": "1.0.3",
    "bitcask_version": "1.6.6-0-g230b6d6",
    "cluster_info_version": "1.2.4",
    "compiler_version": "4.8.1",
    "connected_nodes": [
        "riak@172.17.0.3",
        "riak@172.17.0.4",
        "riak@172.17.0.5",
        "riak@172.17.0.6"
    ],
    "converge_delay_last": 42780,
    "converge_delay_max": 91494,
    "converge_delay_mean": 46533,
    "converge_delay_min": 31574,
    "coord_redirs_total": 0,
    "cpu_avg1": 133,
    "cpu_avg15": 79,
    "cpu_avg5": 125,
    "cpu_nprocs": 860,
    "crypto_version": "2.1",
    "dropped_vnode_requests_total": 0,
    "erlang_js_version": "1.2.2",
    "erlydtl_version": "0.7.0",
    "executing_mappers": 0,
    "goldrush_version": "0.1.5",
    "gossip_received": 115,
    "handoff_timeouts": 0,
    "ignored_gossip_total": 0,
    "index_fsm_active": 0,
    "index_fsm_create": 0,
    "index_fsm_create_error": 0,
    "inets_version": "5.9",
    "kernel_version": "2.15.1",
    "lager_version": "2.0.1",
    "leveldb_read_block_error": "undefined",
    "list_fsm_active": 0,
    "list_fsm_create": 0,
    "list_fsm_create_error": 0,
    "mem_allocated": 961228800,
    "mem_total": 1048956928,
    "memory_atom": 504409,
    "memory_atom_used": 488793,
    "memory_binary": 86568,
    "memory_code": 10776950,
    "memory_ets": 5417656,
    "memory_processes": 10152678,
    "memory_processes_used": 10152664,
    "memory_system": 50191362,
    "memory_total": 60344040,
    "merge_index_version": "1.3.2-0-gcb38ee7",
    "mochiweb_version": "1.5.1p6",
    "node_get_fsm_active": 0,
    "node_get_fsm_active_60s": 0,
    "node_get_fsm_in_rate": 0,
    "node_get_fsm_objsize_100": 0,
    "node_get_fsm_objsize_95": 0,
    "node_get_fsm_objsize_99": 0,
    "node_get_fsm_objsize_mean": 0,
    "node_get_fsm_objsize_median": 0,
    "node_get_fsm_out_rate": 0,
    "node_get_fsm_rejected": 0,
    "node_get_fsm_rejected_60s": 0,
    "node_get_fsm_rejected_total": 0,
    "node_get_fsm_siblings_100": 0,
    "node_get_fsm_siblings_95": 0,
    "node_get_fsm_siblings_99": 0,
    "node_get_fsm_siblings_mean": 0,
    "node_get_fsm_siblings_median": 0,
    "node_get_fsm_time_100": 0,
    "node_get_fsm_time_95": 0,
    "node_get_fsm_time_99": 0,
    "node_get_fsm_time_mean": 0,
    "node_get_fsm_time_median": 0,
    "node_gets": 0,
    "node_gets_total": 0,
    "node_put_fsm_active": 0,
    "node_put_fsm_active_60s": 0,
    "node_put_fsm_in_rate": 0,
    "node_put_fsm_out_rate": 0,
    "node_put_fsm_rejected": 0,
    "node_put_fsm_rejected_60s": 0,
    "node_put_fsm_rejected_total": 0,
    "node_put_fsm_time_100": 0,
    "node_put_fsm_time_95": 0,
    "node_put_fsm_time_99": 0,
    "node_put_fsm_time_mean": 0,
    "node_put_fsm_time_median": 0,
    "node_puts": 0,
    "node_puts_total": 0,
    "nodename": "riak@172.17.0.2",
    "os_mon_version": "2.2.9",
    "pbc_active": 0,
    "pbc_connects": 0,
    "pbc_connects_total": 0,
    "pipeline_active": 0,
    "pipeline_create_count": 0,
    "pipeline_create_error_count": 0,
    "pipeline_create_error_one": 0,
    "pipeline_create_one": 0,
    "postcommit_fail": 0,
    "precommit_fail": 0,
    "public_key_version": "0.15",
    "read_repairs": 0,
    "read_repairs_total": 0,
    "rebalance_delay_last": 0,
    "rebalance_delay_max": 0,
    "rebalance_delay_mean": 0,
    "rebalance_delay_min": 0,
    "rejected_handoffs": 0,
    "riak_api_version": "1.4.4-0-g395e6fd",
    "riak_control_version": "1.4.4-0-g9a74e57",
    "riak_core_stat_ts": 1396648354,
    "riak_core_version": "1.4.4",
    "riak_kv_stat_ts": 1396648353,
    "riak_kv_version": "1.4.8-0-g7545390",
    "riak_kv_vnodeq_max": 0,
    "riak_kv_vnodeq_mean": 0,
    "riak_kv_vnodeq_median": 0,
    "riak_kv_vnodeq_min": 0,
    "riak_kv_vnodeq_total": 0,
    "riak_kv_vnodes_running": 54,
    "riak_pipe_stat_ts": 1396648353,
    "riak_pipe_version": "1.4.4-0-g7f390f3",
    "riak_pipe_vnodeq_max": 0,
    "riak_pipe_vnodeq_mean": 0,
    "riak_pipe_vnodeq_median": 0,
    "riak_pipe_vnodeq_min": 0,
    "riak_pipe_vnodeq_total": 0,
    "riak_pipe_vnodes_running": 39,
    "riak_search_version": "1.4.8-0-gbe6e4ed",
    "riak_sysmon_version": "1.1.3",
    "ring_creation_size": 64,
    "ring_members": [
        "riak@172.17.0.2",
        "riak@172.17.0.3",
        "riak@172.17.0.4",
        "riak@172.17.0.5",
        "riak@172.17.0.6"
    ],
    "ring_num_partitions": 64,
    "ring_ownership": "[{'riak@172.17.0.2',16},\n {'riak@172.17.0.3',12},\n {'riak@172.17.0.4',12},\n {'riak@172.17.0.5',12},\n {'riak@172.17.0.6',12}]",
    "rings_reconciled": 76,
    "rings_reconciled_total": 88,
    "runtime_tools_version": "1.8.8",
    "sasl_version": "2.2.1",
    "sidejob_version": "0.2.0",
    "ssl_version": "5.0.1",
    "stdlib_version": "1.18.1",
    "storage_backend": "riak_kv_bitcask_backend",
    "syntax_tools_version": "1.6.8",
    "sys_driver_version": "2.0",
    "sys_global_heaps_size": 0,
    "sys_heap_type": "private",
    "sys_logical_processors": 2,
    "sys_otp_release": "R15B01",
    "sys_process_count": 1250,
    "sys_smp_support": true,
    "sys_system_architecture": "x86_64-unknown-linux-gnu",
    "sys_system_version": "Erlang R15B01 (erts-5.9.1) [source] [64-bit] [smp:2:2] [async-threads:64] [kernel-poll:true]",
    "sys_thread_pool_size": 64,
    "sys_threads_enabled": true,
    "sys_wordsize": 8,
    "vnode_gets": 0,
    "vnode_gets_total": 0,
    "vnode_index_deletes": 0,
    "vnode_index_deletes_postings": 0,
    "vnode_index_deletes_postings_total": 0,
    "vnode_index_deletes_total": 0,
    "vnode_index_reads": 0,
    "vnode_index_reads_total": 0,
    "vnode_index_refreshes": 0,
    "vnode_index_refreshes_total": 0,
    "vnode_index_writes": 0,
    "vnode_index_writes_postings": 0,
    "vnode_index_writes_postings_total": 0,
    "vnode_index_writes_total": 0,
    "vnode_puts": 0,
    "vnode_puts_total": 0,
    "webmachine_version": "1.10.4-0-gfcff795"
}
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
