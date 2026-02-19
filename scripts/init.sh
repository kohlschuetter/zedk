#!/bin/bash
#
# Initializes the project and its dependencies
# Copyright 2026 Christian Kohlschuetter
#

set -e
verbose=0
clean=0

while [[ 1 ]]; do
case $1 in
  -v)
    verbose=1
    shift
    ;;
  -c)
    clean=1
    shift
    ;;
  -C)
    clean=0
    shift
    ;;
  *)
    break
esac
done

ref="$1"
refName=$ref
refName=${refName:=<current>}
cd $(dirname $0)/..

baseDir=$(pwd)

if [[ ! -e "dependencies/edk2/.git" ]]; then
  git submodule update --init --recursive
fi

mkdir -p ${baseDir}/worktrees
worktreeAdd=1
if [[ -z "$ref" ]]; then
  worktreeDirRel=dependencies/edk2
  worktreeAdd=0
else
  worktreeRef=${ref}
  worktreeDirRel=worktrees/${worktreeRef}
fi
(
  cd ${baseDir}/worktrees
  rm -f current
  ln -sf ../${worktreeDirRel} current
)
worktreeDir="${baseDir}/${worktreeDirRel}"

if [[ $worktreeAdd -eq 1 ]]; then
  cd dependencies/edk2
  echo "Resetting edk2 repo... ref=${refName}"
  if [[ $clean -eq 1 ]]; then
    echo "Cleaning..."
    rm -rf "$worktreeDir"
  fi
  git worktree add -f "${worktreeDir}" $ref || true
fi

cd "${worktreeDir}"
git submodule update --init

tag=$(git describe --tags --dirty)
echo "Tag: $tag"
if [[ -z "$tag" ]]; then
  echo "Error: Could not determine tag" >&2
  exit 1
fi

targetDir=${baseDir}/target/build/${tag}
mkdir -p "${targetDir}"

if [[ $clean -eq 1 ]]; then
  echo Cleaning target folder: ${targetDir}
  rm -rfv "${targetDir}/"*
fi

echo "Building BaseTools..."

if [[ $verbose -eq 0 ]]; then
  set +e
  make -C BaseTools >/dev/null 2>&1
  rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then
    echo "Building BaseTools failed; run \"./scripts/init.sh -v $ref\" for details" >&2
    exit 1
  fi
else
  make -C BaseTools 
fi

echo "done"
