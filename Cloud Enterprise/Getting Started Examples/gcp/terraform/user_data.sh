#!/usr/bin/env bash

# Sets up instance based on https://www.elastic.co/guide/en/cloud-enterprise/1.1/ece-prereqs.html

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

set -euxo pipefail

IMAGE_USER=elastic

apt-key adv --keyserver keyserver.ubuntu.com --recv 58118E89F3A912897C070ADBF76221572C52609D
echo deb https://apt.dockerproject.org/repo ubuntu-xenial main > /etc/apt/sources.list.d/docker.list
apt-get -qq update

apt-get install -y "docker-engine=1.11.2-0~xenial"

usermod -G docker,sudo "${IMAGE_USER}"

mkdir -p /mnt/data/elastic
chown -R "${IMAGE_USER}":"${IMAGE_USER}" /mnt/data/elastic

sysctl -w vm.max_map_count=262144
