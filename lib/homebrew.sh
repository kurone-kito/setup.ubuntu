#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

if [ ! -d "/home/linuxbrew/.linuxbrew" ]
then
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash -
  echo >> "${HOME}/.bashrc"
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "${HOME}/.bashrc"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

brew update
brew bundle --file=lib/Brewfile
brew upgrade
