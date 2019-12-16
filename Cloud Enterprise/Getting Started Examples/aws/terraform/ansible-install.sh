#!/usr/bin/env bash

# Short form: set -u
set -o nounset
# Short form: set -e
set -o errexit

# Print a helpful message if a pipeline with non-zero exit code causes the
# script to exit as described above.
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR

# Allow the above trap be inherited by all functions in the script.
#
# Short form: set -E
set -o errtrace

# Return value of a pipeline is the value of the last (rightmost) command to
# exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully.
set -o pipefail

# Set $IFS to only newline and tab.
#
# http://www.dwheeler.com/essays/filenames-in-shell.html
IFS=$'\n\t'

###############################################################################
# Program Functions
###############################################################################
_write_ansible_playbook() {
cat << PLAYBOOK > ./ece.yml
---
- hosts: primary
  gather_facts: true
  roles:
    - ansible-elastic-cloud-enterprise
  vars:
    ece_primary: true
    ece_version: ${ece-version}

- hosts: secondary
  gather_facts: true
  roles:
    - ansible-elastic-cloud-enterprise
  vars:
    ece_roles: [director, coordinator, proxy, allocator]
    ece_version: ${ece-version}

- hosts: tertiary
  gather_facts: true
  roles:
    - ansible-elastic-cloud-enterprise
  vars:
    ece_roles: [director, coordinator, proxy, allocator]
    ece_version: ${ece-version}
PLAYBOOK
}

_write_ansible_hosts() {
cat << HOSTS_FILE > ./hosts
[primary]
${ece-server0}

[primary:vars]
availability_zone=${ece-server0-zone}

[secondary]
${ece-server1}

[secondary:vars]
availability_zone=${ece-server1-zone}

[tertiary]
${ece-server2}

[tertiary:vars]
availability_zone=${ece-server2-zone}

[aws:children]
primary
secondary
tertiary

[aws:vars]
ansible_ssh_private_key_file=${key}
ansible_user=${user}
ansible_become=yes
device_name=${device}
HOSTS_FILE
}

_run_ansible() {
  export ANSIBLE_HOST_KEY_CHECKING=False
  ansible-playbook -i hosts ece.yml
}

###############################################################################
# Main
###############################################################################

# _main()
#
# Usage:
#   _main [<options>] [<arguments>]
#
# Description:
#   Entry point for the program, handling basic option parsing and dispatching.
_main() {
    _write_ansible_playbook
    _write_ansible_hosts
    sleep 30
    _run_ansible
}

# Call `_main` after everything has been defined.
_main "$@"