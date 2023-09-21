#!/bin/bash

set -euxpv

USAGE="USAGE:
${0}"

if [[ $# > 0 ]]; then
    echo "${USAGE}" >&2
    exit 1
fi

clean_up(){
    rm -rf go1.20.5.linux-amd64.tar.gz
}

# Trap the EXIT signal and execute clean_up function
trap clean_up EXIT

install_prerequisites() {
    # Install Git
    sudo apt-get install -y build-essential libgmp3-dev git
    sudo add-apt-repository ppa:ethereum/ethereum
    sudo apt update -y

    # Setup Go from binaries
    wget https://go.dev/dl/go1.20.5.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
}

install_geth() {
    sudo apt-get install ethereum -y
    # sudo apt-get upgrade geth
    cd ../..
    mkdir home/geth
    sudo chmod -R a+rwX /home/geth  # adjust permissions
    geth version
}

# install Git -> setup Go
echo "Install prerequisites..."
install_prerequisites
# verify go installation
which go
go version
# install geth client via ppa
install_geth
