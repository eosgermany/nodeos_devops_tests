#!/bin/bash -x
self=`basename "$0" | sed 's/.\{3\}$//'`
source "$(dirname "$0")/shared/includes.inc.sh"

init_nodeos_env .$self
init_scenario_block_100 .$self

# ----- STEP1 -----
log=.$self/nodeos.log.$$; mkfifo $log

# Replay with producer plugin and with full state history plugin
(
nodeos_exec .$self \
 --wasm-runtime wabt \
 --disable-replay-opts  \
 --hard-replay-blockchain  \
 --plugin eosio::chain_api_plugin \
 --plugin eosio::chain_plugin \
 2>&1
)|tee $log &

sleep 10
timeout 10 cat $log | grep -qPz "blocks replayed(.|\n)*Blockchain started;"

# get_block requests with valid values are fine
for i in `seq 1 5`;
 do
    echo $i
    sleep 1
	log_curl=.$self/nodeos.log.$$.$RANDOM
	(
  		curl -X POST http://127.0.0.1:8888/v1/chain/get_block -d '{"block_num_or_id": "1"}' | jq \
  		2>&1
	) > $log_curl
	cat $log_curl | grep -q "block_num"
 done    

# get_block requests with invalid (-1) cause nodeos to close the socket
# in the nodeos log the following error can be seen: 
# thread-0  http_plugin.cpp:580           handle_exception     ] FC Exception encountered while processing chain.get_block
for i in `seq 1 5`;
 do
    echo $i
    sleep 1
	log_curl=.$self/nodeos.log.$$.$RANDOM
	(
  		curl --max-time 2 -X POST http://127.0.0.1:8888/v1/chain/get_block -d '{"block_num_or_id": "-1"}' \
  		2>&1
	) > $log_curl
 done  


cat $log_curl | grep -q "Connection refused"

testcase_report $self $?
nodeos_kill_INT
clean_nodeos_env  .$self


