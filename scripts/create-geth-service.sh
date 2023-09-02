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

clean_up(){
    # Remove the temporary sed script file
    rm sed_script.sed
}

on_startup() {
    # on startup
    echo "Verify ${SERVICE_NAME} service..."
    sudo systemctl enable $SERVICE_NAME
}

trap clean_up EXIT
trap on_startup EXIT


setup_service() {
    #  create the service file and copy it to system services folder
    EXEC_LINE="/bin/bash /usr/bin/${SERVICE_NAME}"
    USER_NAME="geth"
    USER_GROUP="geth"
    DOCS_LINK="https://geth.ethereum.org/docs"

    # Create a sed script file for multiline replacements
    cat << EOF > sed_script.sed
s/SERVICE_NAME/${SERVICE_NAME}/g
s/EXEC_LINE/${EXEC_LINE}/g
s/USER_NAME/${USER_NAME}/g
s/USER_GROUP/${USER_GROUP}/g
s/DOCS_LINK/${DOCS_LINK}/g
EOF

    # Apply the sed script to the template file
    sed -f sed_script.sed ./configs/void.service.template > ./${SERVICE_NAME}.service
    sudo cp ./${SERVICE_NAME}.service /etc/systemd/system/${SERVICE_NAME}.service
    sudo chmod 644 /etc/systemd/system/${SERVICE_NAME}.service
    
}

verify_service() {
    #  verify service
    sudo systemctl start $SERVICE_NAME
    sudo systemctl status $SERVICE_NAME
    sudo journalctl -u $SERVICE_NAME -r -o json-pretty
    
}

# setup script
BASE_NAME=$(basename -- ${SCRIPT_PATH})
sudo cp ${SCRIPT_PATH} "/usr/bin/$(basename -- ${SCRIPT_PATH})"
sudo chmod +x "/usr/bin/$(basename -- ${SCRIPT_PATH})"


echo "Setup ${SERVICE_NAME} service..."
setup_service

echo "Verify ${SERVICE_NAME} service..."
verify_service
