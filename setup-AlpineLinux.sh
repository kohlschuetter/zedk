#!/bin/sh
#
# Installs build-time dependencies on Alpine Linux
# Copyright 2026 Christian Kohlschuetter
#

if [[ $(whoami) != "root" ]]; then
  echo "$0: Please run as root" >&2
  exit 1
fi

apk add bash alpine-sdk git libuuid ossp-uuid-dev nasm util-linux-misc zip rustup
if [[ ! -f "/usr/include/uuid/uuid.h" ]]; then
  echo "Adding link from /usr/include/uuid/uuid.h to /usr/include/uuid.h"
  mkdir -p /usr/include/uuid/
  ( cd /usr/include/uuid/ ; ln -s ../uuid.h )
fi
