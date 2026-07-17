#!/usr/bin/env bash
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(mise activate bash --shims)"

mise install node@latest
mise use -g node@latest

mise install npm:@bitwarden/cli
mise use -g npm:@bitwarden/cli
