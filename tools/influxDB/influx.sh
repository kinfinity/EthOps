#!/bin/bash

set -euxpv

USAGE="USAGE:
${0}"

if [[ $# > 0 ]]; then
    echo "${USAGE}" >&2
    exit 1
fi

sudo apt update

# install influxDB
wget https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.0-linux-amd64.tar.gz
tar xvzf influxdb2-2.7.0-linux-amd64.tar.gz
chmod +x ./influxdb2_linux_amd64/influxd
sudo cp influxdb2_linux_amd64/influxd /usr/local/bin/

# verify influxDB
curl -s https://repos.influxdata.com/influxdb2.key | gpg --import -
wget https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.0-linux-amd64.tar.gz.asc
# gpg --verify influxdb2-2.7.0-linux-amd64.tar.gz.asc influxdb2-2.7.0-linux-amd64.tar.gz
# sudo journalctl -u influxdb.service
# run & detatch process
# sudo ufw allow 8086/tcp
sudo influxd run &


# install influxDB cli
wget https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.7.3-linux-amd64.tar.gz
tar xvzf influxdb2-client-2.7.3-linux-amd64.tar.gz
chmod +x ./influx
sudo cp influx /usr/local/bin/

# influx setup
influx setup \
  --username gethinflux \
  --password influxpswd \
  --org ethgeth \
  --bucket gethinflux-bucket \
  --force
influx config 
influx auth list
influx user list --name gethinflux

