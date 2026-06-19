#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

# /etc/os-release is an external system file ShellCheck cannot follow.
# shellcheck source=/dev/null
. /etc/os-release

OLDS="$(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)"
if [ -n "${OLDS}" ]
then
  # Word-splitting is intentional so each old package is passed to apt as
  # its own argument. The script is POSIX sh, so a bash array is not
  # available.
  # shellcheck disable=SC2086
  sudo apt remove -y ${OLDS} || true
fi
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
