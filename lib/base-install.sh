#!/bin/bash
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

sudo DEBIAN_FRONTEND=noninteractive apt-get install \
  --no-install-recommends -y -qq yq

# NOTE: The yq from apt is kislyuk/yq.
mapfile -t packages < <(yq -r '.packages | sort | .[]' cloud-init.yml)
sudo DEBIAN_FRONTEND=noninteractive apt-get install \
  --no-install-recommends -y -qq "${packages[@]}"
