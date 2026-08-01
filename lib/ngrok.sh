#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc -o /etc/apt/keyrings/ngrok.asc
sudo chmod 0644 /etc/apt/keyrings/ngrok.asc

# ngrok's apt repository publishes Debian suites only, never Ubuntu
# codenames -- ngrok ships a single static binary with a low glibc
# floor, so "buster" is the one build it intends every Debian-family
# distribution (Ubuntu included) to install. This is deliberate, not
# an oversight: do not interpolate UBUNTU_CODENAME/VERSION_CODENAME
# here, every Ubuntu codename 404s against this repository.
echo "deb [signed-by=/etc/apt/keyrings/ngrok.asc] https://ngrok-agent.s3.amazonaws.com buster main" \
  | sudo tee /etc/apt/sources.list.d/ngrok.list >/dev/null

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install \
  --no-install-recommends -y -qq ngrok

