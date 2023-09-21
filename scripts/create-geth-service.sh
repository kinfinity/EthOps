#!/bin/bash

set -eu

USAGE="USAGE:
${0} <service-name> <service-script>"

if [[ $# -ne 2 ]]; then
    echo "${USAGE}" >&2
    exit 1
fi

SERVICE_NAME=${1}
SCRIPT_PATH=${2}

# bug fix
sudo apt install --reinstall systemd -y --force-yes

clean_up(){
    # Clean Up
    find . -type f -name "${SERVICE_NAME}.service" -delete
}

on_startup() {
    # on startup
    echo "Verify ${SERVICE_NAME} service..."
    sudo systemctl enable $SERVICE_NAME
}

trap clean_up EXIT
trap on_startup EXIT

setup_user(){
    sudo useradd "geth"
    # sudo usermod -aG systemd-journal "geth"
    # sudo usermod -aG sudo "geth"
    sudo usermod -aG "geth" "geth"
}

setup_service() {
    #  create the service file and copy it to system services folder
    EXEC_LINE="/bin/bash /usr/bin/$(basename -- ${SCRIPT_PATH})"
    USER_NAME="geth"
    USER_GROUP="geth"
    DOCS_LINK="https://geth.ethereum.org/docs"

    # Apply the sed replacement to the template file
    sed -i "
        s#SERVICE_NAME#${SERVICE_NAME}#g
        s#EXEC_LINE#${EXEC_LINE}#g
        s#USER_NAME#${USER_NAME}#g
        s#USER_GROUP#${USER_GROUP}#g
        s#DOCS_LINK#${DOCS_LINK}#g
    " configs/void.service.template
    sudo cp configs/void.service.template  "${SERVICE_NAME}.service"

    cat ${SERVICE_NAME}.service
    sudo cp ${SERVICE_NAME}.service /etc/systemd/system/${SERVICE_NAME}.service
    sudo chmod 644 /etc/systemd/system/${SERVICE_NAME}.service
    
}

verify_service() {
    #  verify service
    sudo systemctl start $SERVICE_NAME
    sleep 25
    sudo systemctl status $SERVICE_NAME
    sudo journalctl -u $SERVICE_NAME -r -o json-pretty
}

# setup script
BASE_NAME=$(basename -- ${SCRIPT_PATH})
sudo cp ${SCRIPT_PATH} "/usr/bin/$(basename -- ${SCRIPT_PATH})"
sudo chmod +x "/usr/bin/$(basename -- ${SCRIPT_PATH})"
cat "/usr/bin/$(basename -- ${SCRIPT_PATH})"

setup_user

echo "Setup ${SERVICE_NAME} service..."
setup_service

echo "Verify ${SERVICE_NAME} service..."
verify_service
