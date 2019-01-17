#!/bin/bash 
self=`basename "$0" | sed 's/.\{3\}$//'`
source "$(dirname "$0")/shared/includes.inc.sh"

init_nodeos_env .$self
init_scenario_block_100 .$self


# ----- STEP1 -----
log=.$self/nodeos.log.$$

(
blocklog_exec .$self \
 --first 1 \
 --last 1  \
 2>&1
) > $log

cat $log | grep -q "what: database file not found at"

testcase_report $self $?
clean_nodeos_env  .$self


