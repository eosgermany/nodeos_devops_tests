
dir=$(echo $(pwd) | rev | cut -d'/' -f3- | rev)
(cd ../runtimes && ./ubuntu_18.04_eosio_1.5.x_latest_build.sh)

docker run  \
 -v $dir:/nodeos_devops_tests \
 -p 8888:8888 -p 9876:9876 \
 -w "/nodeos_devops_tests/unit" \
 -t -i eosio/eos:v1.5.x /bin/bash ./testsuite.sh
