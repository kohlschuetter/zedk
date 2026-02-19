#!/bin/sh
#
# Runs the build, assuming an Alpine Linux 3.23 environment (or compatible)
# Copyright 2026 Christian Kohlschuetter
#

cd $(dirname $0)
./scripts/setup-AlpineLinux.sh
./scripts/clean.sh
./scripts/suite.sh -c
