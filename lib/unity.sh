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

curl -fsSL https://public-cdn.cloud.unity3d.com/hub/prod/cli/install.sh | bash -
