#!/bin/sh
#
# Runs the build in a container
# Copyright 2026 Christian Kohlschuetter
#

cd $(dirname $0)/..
dir=$(pwd)

container="$1"
if [[ -z "$container" ]]; then
  for c in container podman docker; do
    container=$(which "$c") && break
  done
fi
if [[ -z "$container" ]]; then
  echo "Could not determine path to container system" >&2
  if [[ -e /etc/alpine-release ]]; then
    echo "Alpine Linux detected; trying to build without container" >&2
    exec ./scripts/build-alpine.sh
  else
    exit 1
  fi
fi

cat <<EOT
zedk
Copyright 2026 Christian Kohlschuetter

Using container system: $container
Override by specifying path to container app as argument: $0 <path-to-container-app>

EOT

set -x
${container} run --volume ${dir}:/zedk -it alpine:3.23 ./zedk/scripts/build-alpine.sh
