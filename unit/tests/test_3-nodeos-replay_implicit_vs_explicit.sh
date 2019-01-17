#!/bin/bash 
self=`basename "$0" | sed 's/.\{3\}$//'`
source "$(dirname "$0")/shared/includes.inc.sh"

init_nodeos_env .$self
init_scenario_block_1000 .$self

# ----- STEP1 -----
log=.$self/nodeos.log.$$; mkfifo $log

# The replay is implicit executed?
(
nodeos_exec .$self \
 --wasm-runtime wabt \
 2>&1
)|tee $log &


sleep 10
timeout 30 cat $log | grep -q "blocks replayed"
nodeos_kill_INT

# ----- STEP2 -----

# cleanup & init env
clean_nodeos_env  .$self
init_nodeos_env .$self
init_scenario_block_1000 .$self
log=.$self/nodeos.log.$$; mkfifo $log

# The replay is explicitly triggered!
(
nodeos_exec .$self \
 --wasm-runtime wabt \
 --disable-replay-opts  \
 --hard-replay-blockchain  \
 --plugin eosio::chain_api_plugin \
 2>&1
)|tee $log &


sleep 10
timeout 30 cat $log | grep -qPz "blocks replayed(.|\n)*Blockchain started;"

testcase_report $self $?
nodeos_kill_INT
clean_nodeos_env  .$self
