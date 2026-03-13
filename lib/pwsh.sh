#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

. /etc/os-release

curl -fsSL "https://packages.microsoft.com/config/${ID}/${VERSION_ID}/packages-microsoft-prod.deb" \
  | sudo dpkg -i -

sudo apt-get update
sudo apt-get install -y --no-install-recommends powershell
