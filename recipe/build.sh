#!/bin/bash

set -ex

# strip debugging info
export LDFLAGS="$LDFLAGS -s"

# de-init unneeded qemu submodule
git -C ./riscv-gnu-toolchain submodule deinit --force qemu

NPROC=$CPU_COUNT ./build-toolchains.sh --prefix $PREFIX/riscv-tools --clean-after-install

# create activate & deactivate scripts that manage the toolchain
mkdir -p "${PREFIX}"/etc/conda/{de,}activate.d

perl -pe 's/\@NATURE\@/activate/' "${RECIPE_DIR}"/activate.sh > "${PREFIX}"/etc/conda/activate.d/activate-${PKG_NAME}.sh
perl -pe 's/\@NATURE\@/deactivate/' "${RECIPE_DIR}"/activate.sh > "${PREFIX}"/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh
