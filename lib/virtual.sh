#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

if ! command -v terraform >/dev/null 2>&1
then
  echo "Error: terraform command not found" >&2
  exit 1
fi

terraform init
terraform apply -auto-approve

VM='setup-ubuntu'
multipass stop "${VM}"
multipass snapshot -n vanilla "${VM}" || true
multipass restore -d "${VM}.vanilla"
multipass start "${VM}"

tar --format ustar -cvf "${VM}.tar" cloud-init.yml etc/**/* lib/* setup
multipass transfer "${VM}.tar" "${VM}:.local/src/setup-ubuntu.tar"
multipass exec "${VM}" -- /usr/local/bin/setup-ubuntu
