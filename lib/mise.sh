#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

mise install dotnet@8
mise install dotnet@10
mise install dotnet@latest
mise use -g dotnet@latest
