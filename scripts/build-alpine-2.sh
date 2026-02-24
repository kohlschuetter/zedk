#!/bin/bash
#
# Runs the build, assuming an Alpine Linux 3.23 environment (or compatible)
# Copyright 2026 Christian Kohlschuetter
#

cd $(dirname $0)/..
set -e

clean=1
initArgs=(-c)
while [[ 1 ]]; do
case $1 in
   -C)
     clean=0
     initArgs+=($1)
     shift
     ;;
   -*)
     initArgs+=($1)
     shift
     ;;
  *)
    break
esac
done

if [[ $clean -eq 1 ]]; then
	echo CLEAN
  ./scripts/clean.sh
fi
./scripts/suite.sh ${initArgs[@]}
