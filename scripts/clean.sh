#!/bin/sh
#
# Cleans any objects created at build time
# Copyright 2026 Christian Kohlschuetter
#

cd $(dirname $0)/..
git submodule --quiet foreach --recursive 'git clean -fXd'
git clean -fXd
