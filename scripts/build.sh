#!/bin/bash
#
# Builds some edk2 code
# Copyright 2026 Christian Kohlschuetter
#

cd $(dirname $0)/..

baseDir=$(pwd)
set -e

clean=0
while [[ 1 ]]; do
case $1 in
  -c)
    clean=1
    shift
    ;;
  -C)
    clean=0
    shift
    ;;
  --)
    break
    ;;
  -*)
    echo "Unknown option: $1" >&2
    exit 1
    ;;
  *)
    break
esac
done

sourceDateEpoch=$(git log -1 --format=%ct)

cd worktrees/current
edkDir=$(pwd)
sourceDateEpochEdk=$(git log -1 --format=%ct)

if [[ $sourceDateEpochEdk -gt $sourceDateEpoch ]]; then
  sourceDateEpoch=$sourceDateEpochEdk
fi

export SOURCE_DATE_EPOCH=$sourceDateEpoch

tag=$(git describe --tags --dirty)
targetDir=${baseDir}/target/build/${tag}

printf "Writing files to: $targetDir\n\n"
mkdir -p "$targetDir"

(
  cd ${baseDir}/target/build
  rm -f current
  ln -sf ${tag} current
)

export WORKSPACE=
export EDK_TOOLS_PATH=
export CONF_PATH=

if [[ $# -eq 0 ]]; then
  targets=(
    # Serial port console drivers
    MdeModulePkg/Bus/Pci/PciSioSerialDxe
    MdeModulePkg/Universal/Console/TerminalDxe

    # Setup  related components
    MdeModulePkg/Universal/DisplayEngineDxe
    MdeModulePkg/Universal/SetupBrowserDxe
    MdeModulePkg/Application/UiApp
  
    # uefishell
    ShellPkg/Application/Shell
  )
else
  targets=$@
fi

shift $#
. ./edksetup.sh

export PACKAGES_PATH=$(pwd):${baseDir}/src/efi

if [[ $(uname -m) != "x86_64" ]]; then
  echo "Non-x64 platform detected; enabling crosscompiler"
  export GCC5_BIN=x86_64-elf-
fi

echo Targets: ${targets[@]}

set -e
for target in ${targets[@]}; do
  printf "\n"
  printf "====================================================================================\n"

  pkg=${target%%/*}
  name=${target##*/}

  pkgDsc="${pkg}/${pkg}.dsc"
  modDsc="${target}/${name}.inf"

  baseName=$(grep -m 1 BASE_NAME "$modDsc" | tr '\r' '\n')
  baseName=( ${baseName##*= } )
  [[ -z "$baseName" ]] && baseName=${name}

  printf "*** Building $target\n"
  if [[ $clean -eq 1 ]]; then
    build -p ${pkgDsc} -m ${modDsc} -a X64 -t GCC5 -b RELEASE clean
  fi
  build -p ${pkgDsc} -m ${modDsc} -a X64 -t GCC5 -b RELEASE

  buildName=${pkg%%Pkg}

  case "$baseName" in
    Shell)
      efiName="Shell_EA4BB293-2D7F-4456-A681-1F22F42CD0BC"
      targetName="Shell"
      ;;
    *)
      efiName=${baseName}
      targetName=${efiName}
      ;;
  esac  

  cp -av "${edkDir}/Build/${buildName}/RELEASE_GCC5/X64/${efiName}.efi" "${targetDir}/${targetName}.efi"
done
