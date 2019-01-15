# docker build -t eosio/eos:v1.5.x --build-arg branch=master - < ./ubuntu_18.04_eosio_1.5.x_latest.dockerfile
docker build -t eosio/eos:v1.5.x --build-arg branch=master -f ./ubuntu_18.04_eosio_1.5.x_latest.dockerfile .
