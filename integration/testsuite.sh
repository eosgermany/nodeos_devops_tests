#!/bin/bash -x
dir=$(echo $(pwd) | sed 's,/*[^/]\+/*$,,')
(cd tests && ./unittests_ubuntu_18.04_eosio_1.5.x_latest.sh)

