#!/bin/bash
#
# Builds the full suite of artifacts required for the final product
# Copyright 2026 Christian Kohlschuetter
#

echo zedk suite
echo https://github.com/kohlschuetter/zedk
echo

cd $(dirname $0)/..
targetDir=target/suite
zipOut=$(pwd)/target/zedk2.zip
rm -rf ${targetDir}
mkdir -p ${targetDir}

echo "Using compiler: $(gcc --version | head -n 1)"
echo "Note: Tested with GCC 14 and 15; will fail with clang-gcc."
echo

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
# NOTE: builds older than 202502 won't build with GCC 15 or newer
#tagDisplayEngineDxe=edk2-stable202211
# font bug got introduced somewhere betwen 202508 and 202511
tagDisplayEngineDxe=edk2-stable202508
#tagDisplayEngineDxe=edk2-stable202511
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
