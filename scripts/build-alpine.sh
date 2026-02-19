#!/bin/sh
#
# Runs the build, assuming an Alpine Linux 3.23 environment (or compatible)
# Copyright 2026 Christian Kohlschuetter
#

cd $(dirname $0)/..
set -e
if [[ ! -e "/etc/alpine-release" ]]; then
  echo "Warning: This script requires Alpine Linux; execution may fail. Try running ./build-container.sh instead" >&2
  echo
fi

./scripts/setup-AlpineLinux.sh
./scripts/clean.sh
./scripts/suite.sh -c
