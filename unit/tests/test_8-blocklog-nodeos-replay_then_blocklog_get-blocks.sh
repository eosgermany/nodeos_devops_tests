#!/bin/bash -x
self=`basename "$0" | sed 's/.\{3\}$//'`
source "$(dirname "$0")/shared/includes.inc.sh"

init_nodeos_env .$self
init_scenario_block_100 .$self

# ----- STEP1 -----
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
nodeos_kill_INT

# ----- STEP2 -----
log=.$self/nodeos.log.$$.$RANDOM

(
blocklog_exec .$self \
 --first 1 \
 --last 1  \
 2>&1
) > $log

cat $log | grep -qPz "existing block log contains block num(.|\n)*producer_signature"

testcase_report $self $?
clean_nodeos_env  .$self


