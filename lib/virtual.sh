#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

if ! command -v terraform >/dev/null 2>&1
then
  echo "Error: terraform command not found" >&2
  exit 1
fi

terraform init
terraform apply -auto-approve
