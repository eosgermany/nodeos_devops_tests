#!/bin/bash 

rm -rf ./tests/results.log
rm -rf ./tests/.test*
pkill nodeos

( cd tests && "./test_1-nodeos-replay-required.sh" )
( cd tests && "./test_2-nodeos-replay-then-use-it.sh")
( cd tests && "./test_3-nodeos-replay_implicit_vs_explicit.sh")
( cd tests && "./test_4-nodeos-bootstrap-from-generated-snapshot.sh")
( cd tests && "./test_5-nodeos-replay-w-full-state-history.sh")
( cd tests && "./test_6-nodeos-snapshot-w-full-state-history.sh")
( cd tests && "./test_7-blocklog-get-blocks_no_database.sh")
( cd tests && "./test_8-blocklog-nodeos-replay_then_blocklog_get-blocks.sh")
( cd tests && "./test_9-nodeos-hangs-after-few-invalid-http-requests.sh")
