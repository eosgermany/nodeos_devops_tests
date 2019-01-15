# initialisation utils

eosio_backup_dir="../eosio-backup/"

init_nodeos_env () {
  rm -rf $1/data 
  rm -rf $1/config

  mkdir -p $1/data/blocks
  mkdir -p $1/config
}

clean_nodeos_env() {
	rm -rf $1
}

init_scenario_block_100() {
	cp $eosio_backup_dir/blocks_100.log $1/data/blocks/blocks.log
}