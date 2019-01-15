#!/bin/bash -x

# See https://github.com/EOSIO/fill-postgresql

self=`basename "$0" | sed 's/.\{3\}$//'`
source "$(dirname "$0")/shared/includes.inc.sh"

init_nodeos_env .$self
#init_scenario_block_100 .$self

cp /mnt/disk1/tmp/blocklog/blocks/blocks.log .$self/data/blocks/blocks.log
cp /mnt/disk1/tmp/blocklog/snapshots/snapshot-0236079ab195066729d3c3e749e8b30775948eb277bae0d86c864543eb3534a2.bin \
.$self/data/snapshot-current.bin


# ----- STEP1 -----
log=.$self/nodeos.log.$$; mkfifo $log

# Bootstrap from snapshot
(
nodeos_exec .$self \
 --wasm-runtime wabt \
 --snapshot .$self/data/snapshot-current.bin \
 2>&1
)|tee $log &

sleep 100
timeout 100 cat $log | grep -qPz "blocks replayed(.|\n)*Blockchain started;"

sleep infinity

nodeos_kill_INT

testcase_report $self $?
nodeos_kill_INT
#clean_nodeos_env  .$self
