#!/bin/sh
#
# Cleans any objects created at build time
# Copyright 2026 Christian Kohlschuetter
#

cd $(dirname $0)/..
git clean -fXd
