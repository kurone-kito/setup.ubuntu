#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

# Set locale
sudo locale-gen ja_JP.UTF-8
sudo update-locale LANG=ja_JP.UTF-8

# Set timezone
sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
echo 'Asia/Tokyo' | sudo tee /etc/timezone

# Set keyboard layout
sudo tee /etc/default/keyboard < etc/default/keyboard
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive keyboard-configuration
