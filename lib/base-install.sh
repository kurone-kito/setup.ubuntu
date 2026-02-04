#!/bin/bash
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y --no-install-recommends yq
