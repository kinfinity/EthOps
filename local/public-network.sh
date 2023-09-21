#!/bin/bash

set -eu

USAGE="USAGE:
${0} <vagrant-location> <node-name>"

if [[ $# -ne 2 ]]; then
    echo "${USAGE}" >&2
    exit 1
fi

VAGRANT_LOCATION="${1}"
NODE_NAME="${2}"

export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"

clean_up() {
    echo "Cleaning up..."
    rm -rf "Vagrantfile"
    exit
}
trap clean_up EXIT

invalid_dir() {
    echo "Invalid vagrant directory"
    echo "${USAGE}" >&2 
}

vagrant_run() {
    pushd "${VAGRANT_LOCATION}" > /dev/null

    # Check if the Vagrantfile.template exists
    if [ ! -f "Vagrantfile.template" ]; then
        echo "Vagrantfile.template not found." >&2
        exit 1
    fi
    
    # create vagrantfile
    sed "s/PUB_NODE/${NODE_NAME}/g" "Vagrantfile.template" > "Vagrantfile"

    # Check if the Vagrant box already exists
    box_args=()
    box=$(vagrant global-status | grep $NODE_NAME) || true # Capture the result, or use 'true' to ensure the variable is set
    if ! [ -z "$box" ]; then
        box_args=(${box//:/ })
        if [[ "${box_args[1]}" == "$NODE_NAME" ]]; then
            echo "Destroying existing Vagrant box: ${NODE_NAME}"
            vagrant destroy $NODE_NAME -f
        fi
    fi

    # create & bootstrap VM 
    echo "Creating and provisioning Vagrant box: ${NODE_NAME}"
    vagrant validate
    # vagrant up > vagrant.log # VAGRANT_LOG=info
    VAGRANT_LOG=info vagrant up > vagrant.log # VAGRANT_LOG=debug
    
}

if [[ -d "${VAGRANT_LOCATION}" ]]; then
    vagrant_run
else
    invalid_dir
fi
