
eosio_dist () {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "osx"
    else
        echo "unsupported"
    fi
}

export -f eosio_dist

# set compatibility aliases, need to install coreutils
# brew install coreutils
# this will provide all the g<unix-compatible> commands
if [[ "$(eosio_dist)" == "osx" ]]; then

    # needed to make aliases work
    # over bash files
    # https://unix.stackexchange.com/questions/158038/non-interactive-shell-expand-alias
    shopt -s expand_aliases

    timeout() { perl -e 'alarm shift; exec @ARGV' "$@"; }
    alias timeout=gtimeout
    alias grep=ggrep
fi

# assuming 64 bits
eosio_dist_dir="../../eosio-dist/$(eosio_dist)/eosio-1.5.3-$(eosio_dist)-x86_64/bin"
# eosio_dist_dir="../eosio-dist/linux/eosio-1.6.0-linux-x86_64/bin"


nodeos_pid () {
  pgrep -x nodeos
}

nodeos_kill_INT() {
  pkill  -x nodeos -INT
}

nodeos_exec() {
  eosio_nodeos_dir=$1;shift
  $eosio_dist_dir/nodeos --data-dir $eosio_nodeos_dir/data --config-dir $eosio_nodeos_dir/config \
  --logconf $eosio_nodeos_dir/logging.json "$@"
}


nodeos_exec_explicit() {
    dist_dir=$1;shift
    nodeos_dir=$1;shift
    $dist_dir/nodeos --data-dir $nodeos_dir/data --config-dir $nodeos_dir/config \
                           --logconf $nodeos_dir/logging.json "$@"
}

blocklog_exec() {
  eosio_nodeos_dir=$1;shift
  $eosio_dist_dir/eosio-blocklog --blocks-dir $eosio_nodeos_dir/data/blocks "$@"
}

# prepares a blocks dir, on success we have
# a replayed blocks dir, on failure ..
prepare_blocks_dir() {
    # The replay is explicitly triggered!
    dist_dir=$1;shift
    nodeos_dir=$1;shift

    (
        nodeos_exec_explicit $dist_dir $nodeos_dir \
                    --wasm-runtime wabt \
                    --disable-replay-opts  \
                    --hard-replay-blockchain  \
                    --plugin eosio::chain_api_plugin \
                    2>&1
    )|tee $log &


    sleep 10
    timeout 30 cat $log | grep -qPz "blocks replayed(.|\n)*Blockchain started;"
}


