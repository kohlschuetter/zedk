#!/bin/sh
#
# Installs build-time dependencies on Alpine Linux
# Copyright 2026 Christian Kohlschuetter
#

if [[ $(whoami) != "root" ]]; then
  elev=$(which sudo || which doas)
  if [[ -n "$elev" ]]; then
    echo "$0: This needs to be run as root; trying $elev ..."
    $elev $0 && exit 0
  fi

  echo "$0: Execution failed; please check for errors and run manually as root" >&2
  exit 1
fi

set -e

apk add bash alpine-sdk git libuuid ossp-uuid-dev nasm util-linux-misc zip rustup python3

if [[ $(uname -m) != "x86_64" ]]; then
  echo "Non-x64 platform detected; adding crosscompiler"
  apk add gcc-x86_64-elf
fi

if [[ ! -f "/usr/include/uuid/uuid.h" ]]; then
  echo "Adding link from /usr/include/uuid/uuid.h to /usr/include/uuid.h"
  mkdir -p /usr/include/uuid/
  ( cd /usr/include/uuid/ ; ln -s ../uuid.h )
fi

if [[ ! -f "/usr/lib/libuuid.so" ]]; then
  echo "Adding link from /usr/lib/libuuid.so to /usr/lib/libuuid.so.1"
  ( cd /usr/lib ; ln -s libuuid.so.1 libuuid.so )
fi
