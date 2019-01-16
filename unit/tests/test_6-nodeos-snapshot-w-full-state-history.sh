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
 --plugin eosio::producer_api_plugin  \
 --plugin eosio::state_history_plugin \
 --trace-history \
 --chain-state-history \
 2>&1
)|tee $log &

sleep 10
timeout 10 cat $log | grep -qPz "blocks replayed(.|\n)*Blockchain started;"

snapshot_id=$(curl http://127.0.0.1:8888/v1/producer/create_snapshot |  jq -r '.head_block_id')

nodeos_kill_INT

# ----- STEP2 -----

# flip and create new environment, delete old environment
self_old=$self; self=${self}.$RANDOM
clean_nodeos_env  .$self
init_nodeos_env .$self
init_scenario_block_100 .$self
cp .$self_old/data/snapshots/snapshot-${snapshot_id}.bin .$self/data/snapshots/
cp -r .$self_old/data/state-history .$self/data/
clean_nodeos_env  .$self_old

log=.$self/nodeos.log.$$; mkfifo $log


# Bootstrap from snapshot
(
nodeos_exec .$self \
 --wasm-runtime wabt \
 --snapshot .$self/data/snapshots/snapshot-${snapshot_id}.bin \
 --plugin eosio::state_history_plugin \
 --state-history-endpoint 127.0.0.1:8889 \
 --trace-history \
 --chain-state-history \
 --plugin eosio::chain_api_plugin \
 --disable-replay-opts \
 2>&1
)|tee $log &


sleep 10
timeout 10 cat $log | grep -qPz "chain_state_history.log has blocks(.|\n)*Blockchain started;"

testcase_report $self $?
nodeos_kill_INT
clean_nodeos_env  .$self


