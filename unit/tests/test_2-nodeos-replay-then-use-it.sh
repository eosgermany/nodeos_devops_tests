#!/bin/bash -x
self=`basename "$0" | sed 's/.\{3\}$//'`
source "$(dirname "$0")/shared/includes.inc.sh"

init_nodeos_env .$self
init_scenario_block_1000 .$self

# ----- STEP1 -----
log=.$self/nodeos.log.$$; mkfifo $log

# chain replay required
(
nodeos_exec .$self \
 --wasm-runtime wabt \
 2>&1
)|tee $log &


sleep 10
timeout 30 cat $log | grep -q "No head block in fork db, perhaps we need to replay"
nodeos_kill_INT

# ----- STEP2 -----

# log=.$self/nodeos.log.$$; mkfifo $log

# The replayed chain is used 
(
nodeos_exec .$self \
 --wasm-runtime wabt \
 --plugin eosio::chain_api_plugin \
 2>&1
)|tee $log &


sleep 10
timeout 30 cat $log | grep -q "Blockchain started;"

testcase_report $self $?
nodeos_kill_INT
clean_nodeos_env  .$self