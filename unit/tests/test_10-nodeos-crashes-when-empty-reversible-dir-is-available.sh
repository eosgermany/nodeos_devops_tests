#!/bin/bash
self=`basename "$0" | sed 's/.\{3\}$//'`
source "$(dirname "$0")/shared/includes.inc.sh"


# ----- STEP1 -----

init_nodeos_env .$self
init_scenario_block_1000 .$self
log=.$self/nodeos.log.$$; mkfifo $log

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

# cleanup & init env
clean_nodeos_env  .$self
init_nodeos_env .$self
init_scenario_block_1000 .$self
log=.$self/nodeos.log.$$; mkfifo $log

# Causes the below boost exception when
#  if an empty --data-dir ...data/blocks/reversible is available
#
# nodeos 1.5.3 and 1.6.x
#
# rethrow boost::interprocess_exception::library_error:
#    {"what":"boost::interprocess_exception::library_error"}
#    thread-0  chain_plugin.cpp:707 plugin_initialize
# ⌄⌄⌄
mkdir .$self/data/blocks/reversible

(
nodeos_exec .$self \
 --wasm-runtime wabt \
 --disable-replay-opts  \
 --hard-replay-blockchain  \
 --plugin eosio::chain_api_plugin \
 2>&1
)|tee $log &


sleep 10
timeout 30 cat $log | grep -q "boost::interprocess_exception::library_error"


testcase_report $self $?
nodeos_kill_INT
clean_nodeos_env  .$self
