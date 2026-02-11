#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

. /etc/os-release

OLDS="$(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)"
sudo apt remove -y "${OLDS}" || true
sudo install -m 0755 -d /etc/apt/keyrings
GPG_URL="https://download.docker.com/linux/${ID}/gpg"
sudo curl -fsSL "${GPG_URL}" -o /etc/apt/keyrings/docker.asc
sudo chmod 644 /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/${ID}
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt-get update
sudo apt-get install -y --no-install-recommends containerd.io \
  docker-buildx-plugin docker-ce docker-ce-cli docker-ce-rootless-extras \
  docker-compose-plugin

sudo groupadd docker || true
sudo usermod -aG docker "$USER"
