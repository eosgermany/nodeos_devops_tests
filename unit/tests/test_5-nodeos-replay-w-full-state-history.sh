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
 --state-history-endpoint 127.0.0.1:8889 \
 --trace-history \
 --chain-state-history \
 --filter-on "*" \
 --plugin eosio::chain_api_plugin \
 2>&1
)|tee $log &

sleep 10
timeout 10 cat $log | grep -qPz "blocks replayed(.|\n)*Blockchain started;"

testcase_report $self $?
nodeos_kill_INT
#clean_nodeos_env  .$self


