#!/bin/bash

set -euxpv

USAGE="USAGE:
${0}"

if [[ $# > 0 ]]; then
    echo "${USAGE}" >&2
    exit 1
fi

# creat user
sudo useradd --no-create-home --shell /bin/false prometheus  
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo mkdir /etc/prometheus

sudo apt update -y

setup_forinstall() {
    sudo mkdir /var/lib/prometheus
    for i in rules rules.d files_sd; do sudo mkdir -p /etc/prometheus/${i}; done
}

# Install Prometheus
install_prometheus() {
    mkdir -p /tmp/prometheus && cd /tmp/prometheus
    curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -
    tar xvf prometheus*.tar.gz
    cd prometheus*/
    sudo mv prometheus promtool /usr/local/bin/
}

prometheus_config() {
    sudo mv prometheus.yml /etc/prometheus/prometheus.yml
    sudo mv consoles/ console_libraries/ /etc/prometheus/
    sudo chown prometheus:prometheus /etc/prometheus
    sudo chown prometheus:prometheus /var/lib/prometheus
    sudo chown prometheus:prometheus /usr/local/bin/prometheus
    sudo chown prometheus:prometheus /usr/local/bin/promtool
    sudo chown -R prometheus:prometheus /etc/prometheus/consoles
    sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
    sudo chown -R prometheus:prometheus /etc/prometheus/prometheus.yml
}

setup_forinstall && install_prometheus  && prometheus_config

