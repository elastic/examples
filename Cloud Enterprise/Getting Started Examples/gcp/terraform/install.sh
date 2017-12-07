#!/usr/bin/env bash

# Installs ECE based on https://www.elastic.co/guide/en/cloud-enterprise/1.1/ece-quick-start.html

set -euxo pipefail

PUBLIC_KEY="$(echo var.public_key | terraform console)"
PRIVATE_KEY="$(dirname "${PUBLIC_KEY}")/$(basename -s .pub "${PUBLIC_KEY}")"
REMOTE_USER="$(echo var.remote_user | terraform console)"

SSH_OPTIONS="-o LogLevel=quiet -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
SSH_AUTHENTICATION="-i ${PRIVATE_KEY} -o User=${REMOTE_USER}"

COORDINATOR="$(echo google_compute_instance.server.0.network_interface.0.access_config.0.assigned_nat_ip | terraform console)"
COORDINATOR_IP="$(echo google_compute_instance.server.0.network_interface.0.address | terraform console)"

ALLOCATOR_B="$(echo google_compute_instance.server.1.network_interface.0.access_config.0.assigned_nat_ip | terraform console)"

INSTALL_COMMAND="bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) install"

ece_install() {
  local host="${1}"
  local zone="${2}"
  local options="${3:-}"

  ssh -t ${SSH_OPTIONS} ${SSH_AUTHENTICATION} "${host}" \
    "${INSTALL_COMMAND} --availability-zone ${zone} ${options}"
}

ece_install "${COORDINATOR}" ece-region-1a

scp ${SSH_OPTIONS} ${SSH_AUTHENTICATION} "${COORDINATOR}":/mnt/data/elastic/bootstrap-state/bootstrap-secrets.json .
ROLES_TOKEN="$(jq -r .bootstrap_runner_roles_token bootstrap-secrets.json)"
ROOT_PASSWORD="$(jq -r .adminconsole_root_password bootstrap-secrets.json)"

ece_install "${ALLOCATOR_B}" ece-region-1b "--coordinator-host ${COORDINATOR_IP} --roles-token ${ROLES_TOKEN}"

cat <<TXT

All done!

You can log into your installation at (note that certificate is auto-generated/self-signed for now):

    https://${COORDINATOR}:12443

    Username: root
    Password: ${ROOT_PASSWORD}


If you would like to SSH into a host, please feel free to do so using:

    ssh ${SSH_OPTIONS} ${SSH_AUTHENTICATION} ${COORDINATOR}

TXT
