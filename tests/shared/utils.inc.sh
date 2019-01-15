eosio_dist_dir="../eosio-dist/linux/eosio-1.5.3-linux-x86_64/bin"

nodeos_pid () {
  pgrep -x nodeos
}

nodeos_kill_INT() {
  pkill -x -INT  nodeos
}

nodeos_exec() {
  eosio_nodeos_dir=$1;shift
  $eosio_dist_dir/nodeos --data-dir $eosio_nodeos_dir/data --config-dir $eosio_nodeos_dir/config \
  --logconf $eosio_nodeos_dir/logging.json "$@"
}