#!/usr/bin/env bash
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
SHELL="$(getent passwd | grep "$(whoami)" | cut -d: -f7 | xargs -I{} basename {})"
eval "$(mise activate bash --shims)"
