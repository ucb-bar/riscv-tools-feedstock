#!/bin/bash

set -ex

TOOLCHAIN_NAME=riscv-tools

# strip debugging info
export LDFLAGS="$LDFLAGS -s"

# de-init unneeded qemu submodule
# git -C ./riscv-gnu-toolchain submodule deinit --force qemu

NPROC=$CPU_COUNT ./build-toolchains.sh --prefix $PREFIX/$TOOLCHAIN_NAME --clean-after-install

# create activate & deactivate scripts that manage the toolchain
mkdir -p "${PREFIX}"/etc/conda/{de,}activate.d

perl -pe 's/\@NATURE\@/activate/' "${RECIPE_DIR}"/activate.sh > "${PREFIX}"/etc/conda/activate.d/activate-${PKG_NAME}.sh
perl -pe 's/\@NATURE\@/deactivate/' "${RECIPE_DIR}"/activate.sh > "${PREFIX}"/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh

pushd $PREFIX/$TOOLCHAIN_NAME/sysroot

# Strip $ORIGIN/.*/lib (if it exists) from the RPATH of all sysroot binaries.
# Fixes linux boot (since the RPATH shouldn't be set for the sysroot ld*.so)
shopt -s globstar
for file in ** ;
do
    file -b "${file}" | grep -q 'ELF' || continue
    if output=$(patchelf --print-rpath $file); then
        echo "Current RPATH=$output for FILE=$file"
        if [[ $output == *":"* ]]; then
            mails=$(echo $output | tr ":" "\n")
            new_rpath=""
            for addr in $mails
            do
                if [[ $addr != *"lib"* ]]; then
                    new_rpath="${new_rpath}${addr}:"
                fi
            done
            new_rpath=$(echo $new_rpath | sed 's/.$//')
            patchelf --force-rpath --set-rpath $new_rpath $file
            echo "Modify RPATH=$new_rpath"
        else
            echo "Remove RPATH"
            patchelf --remove-rpath $file
        fi
    else
        # not a elf that we can modify
        echo "Skip FILE=$file"
        continue
    fi
done

popd
