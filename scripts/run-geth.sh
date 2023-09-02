#!/bin/bash

set -eu

USAGE="USAGE:
${0}"

if [[ $# -ne 0 ]]; then
    echo "${USAGE}" >&2
    exit 1
fi

run_geth() {
    geth console --syncmode $1 --http --http.api "eth,debug"
    # geth console --config ../configs/geth_config.toml --syncmode light
}

# not handling other node types yet [ full | archive]
run_geth light

# 
# if [[ -d "geth_data" ]]; then
#     mkdir geth_data
#     geth init --datadir geth_data ./configs/genesis.json
# done
