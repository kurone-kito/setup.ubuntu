#!/bin/bash
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

sudo DEBIAN_FRONTEND=noninteractive apt-get install \
  --no-install-recommends -y -qq yq

# NOTE: The yq from apt is kislyuk/yq. Invoke it by absolute path (not
# a bare `yq`) so this always resolves to that binary even when a
# different yq implementation earlier on PATH (for example, one
# installed by mise) would otherwise shadow it -- the two use
# incompatible CLI syntax.
mapfile -t packages < <(/usr/bin/yq -r '.packages | sort | .[]' cloud-init.yml)
sudo DEBIAN_FRONTEND=noninteractive apt-get install \
  --no-install-recommends -y -qq "${packages[@]}"
