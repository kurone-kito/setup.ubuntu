#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

VM='setup-ubuntu'
tar --format ustar -cvf "${VM}.tar" cloud-init.yml etc/**/* lib/* setup
multipass transfer "${VM}.tar" "${VM}:.local/src/setup-ubuntu.tar"
multipass exec "${VM}" -- /usr/local/bin/setup-ubuntu
