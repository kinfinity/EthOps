#!/bin/bash

set -euxpv

USAGE="USAGE:
${0}"

if [[ $# > 0 ]]; then
    echo "${USAGE}" >&2
    exit 1
fi

docker run -d -p 3000:3000 --name=grafana grafana/grafana-enterprise