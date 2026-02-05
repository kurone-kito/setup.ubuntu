#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew cleanup
sudo apt-get autoremove -y
sudo apt-get clean
