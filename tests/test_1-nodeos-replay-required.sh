#!/bin/bash -x
self=`basename "$0" | sed 's/.\{3\}$//'`
source "$(dirname "$0")/shared/init.inc.sh"
source "$(dirname "$0")/shared/utils.inc.sh"

init_nodeos_env .$self
init_scenario_block_100 .$self

log=.$self/nodeos.log.$$; mkfifo $log

#
(
nodeos_exec .$self $log \
 --wasm-runtime wabt \
)&

sleep 5
timeout 5 cat $log | grep -q "No head block in fork db, perhaps we need to replay"

nodeos_kill_INT
#clean_nodeos_env  .$self