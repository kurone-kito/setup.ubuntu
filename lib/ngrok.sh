#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

# /etc/os-release is an external system file ShellCheck cannot follow.
# shellcheck source=/dev/null
. /etc/os-release

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc -o /etc/apt/keyrings/ngrok.asc
sudo chmod 0644 /etc/apt/keyrings/ngrok.asc

echo "deb [signed-by=/etc/apt/keyrings/ngrok.asc] https://ngrok-agent.s3.amazonaws.com ${UBUNTU_CODENAME:-$VERSION_CODENAME} main" \
  | sudo tee /etc/apt/sources.list.d/ngrok.list >/dev/null

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install \
  --no-install-recommends -y -qq ngrok

