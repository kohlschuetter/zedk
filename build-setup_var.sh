#!/bin/bash

cd $(dirname $0)
srcDir=$(pwd)/dependencies/setup_var.efi
targetDir=$(pwd)/target/setup_var
mkdir -p "${targetDir}"

export RUSTUP_HOME="${targetDir}/rustup"
export CARGO_HOME="${targetDir}/cargo"

rustup-init --no-modify-path -y -q

. "$CARGO_HOME/env"

cd ${srcDir}
cargo build --release
