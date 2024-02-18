#!/bin/bash

set -eu

USAGE="USAGE:
${0} <service-name>"

if [[ $# -ne 1 ]]; then
    echo "${USAGE}" >&2
    exit 1
fi

SERVICE_NAME=${1}

#  setup service
mv /home/vagrant/configs/prom.service.template ./${SERVICE_NAME}.service
sudo mv ./${SERVICE_NAME}.service /etc/systemd/system/${SERVICE_NAME}.service
sudo chmod 644 /etc/systemd/system/${SERVICE_NAME}.service

#  verify service
sudo systemctl daemon-reload
sudo systemctl start $SERVICE_NAME
sudo systemctl status $SERVICE_NAME
sudo journalctl -u $SERVICE_NAME -r -o json-pretty

# on startup
sudo systemctl enable $SERVICE_NAME
sudo ufw allow 9090/tcp
