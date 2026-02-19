#!/bin/bash
#
# Builds the full suite of artifacts required for the final product
# Copyright 2026 Christian Kohlschuetter
#

cd $(dirname $0)
targetDir=target/suite
zipOut=$(pwd)/target/zedk2.zip
rm -rf ${targetDir}
mkdir -p ${targetDir}

initArgs=()

while [[ 1 ]]; do
case $1 in
  -v|-c|-C)
    initArgs+=($1)
    shift
    ;;
  *)
    break
esac
done

set -e

# latest DisplayEngineDxe has a bug with fonts, so let's use an older one
tagDisplayEngineDxe=edk2-stable202211
./scripts/init.sh ${initArgs[@]} ${tagDisplayEngineDxe}
./scripts/build.sh MdeModulePkg/Universal/DisplayEngineDxe

# use a custom branch of edk2 by default (which is defined by the submodule commit)
# ./scripts/init.sh ${initArgs[@]} master
./scripts/init.sh ${initArgs[@]}
./scripts/build.sh
# Our custom branch has additional programs
./scripts/build.sh ShellPkg/Application/UnloadUUID

cp -av src/suite/* ${targetDir}
cp -av target/build/current/* ${targetDir}
cp -av target/build/${tagDisplayEngineDxe}/DisplayEngine.efi ${targetDir}
mkdir -p ${targetDir}/EFI/BOOT
cp -av ${targetDir}/Shell.efi ${targetDir}/EFI/BOOT/bootx64.efi

./scripts/build-setup_var.sh
cp -av dependencies/setup_var.efi/target/x86_64-unknown-uefi/release/setup_var.efi ${targetDir}/

cd ${targetDir}
rm -f ${zipOut}
zip -r ${zipOut} .

echo
echo "Target zipfile is at: ${zipOut}"

echo done
