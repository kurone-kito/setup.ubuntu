#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

# Unity has not published a stable release manifest yet (the stable
# manifest 404s); the beta channel is the only one that currently
# resolves. Pinned in this one place so it can be dropped once Unity
# publishes a stable manifest.
UNITY_CLI_CHANNEL=beta
export UNITY_CLI_CHANNEL

# Download to a temp file first: `curl ... | bash -` would let a failed
# curl exit the pipeline at 0 (bash runs on an empty stdin), silently
# skipping the install instead of failing this stage.
installer="$(mktemp)"
trap 'rm -f "$installer"' EXIT
curl -fsSL https://public-cdn.cloud.unity3d.com/hub/prod/cli/install.sh -o "$installer"
bash "$installer"
