#!/bin/bash -x

rm -rf ./results.log

( exec "tests/test_1-nodeos-replay-required.sh" )
( exec "tests/test_2-nodeos-replay-then-use-it.sh")
( exec "tests/test_3-nodeos-replay_implicit_vs_explicit.sh")
( exec "tests/test_4-nodeos-bootstrap-from-generated-snapshot.sh")
( exec "tests/test_5-nodeos-replay-w-full-state-history.sh")
( exec "tests/test_6-nodeos-snapshot-w-full-state-history.sh")