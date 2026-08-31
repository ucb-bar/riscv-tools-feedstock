#!/bin/bash

set -ex

TOOLCHAIN_NAME=riscv-tools

# --- Knobs ------
# ARCH / ABI : leave empty to use the toolchain default. With MULTILIB=1 the
#              toolchain builds the full multilib set and ARCH/ABI, in which 
#              this targets what the default march would be
#              Defaults: ARCH=rv64gc  ABI=lp64d
# MULTILIB   : 1 to build multilib variants (--enable-multilib), empty to disable
ARCH="rv64gc"
ABI="lp64d"
MULTILIB=1 # enables -march=rv64gcv, -march=rv32i etc

# TOOLCHAIN_GCC: which gcc version to target
#   16 -> gcc-16 / gdb-16 / binutils-2.46  (tag 2026.07.12) - lts
#   14 -> gcc-14 / gdb-15 / binutils-2.44  (tag 2025.05.01) - last gcc-14 toolchain upstream
# to change to other versions, search `2026.07.12` to go to snippet
TOOLCHAIN_GCC="${TOOLCHAIN_GCC:-16}"
# ------------------------------------------------------------------------------

# strip debugging info
export LDFLAGS="$LDFLAGS -s"

# sourceware is flaky, use mirrors
git config --global url."https://github.com/gnutools/binutils-gdb.git".insteadOf "https://sourceware.org/git/binutils-gdb.git"
git config --global url."https://github.com/bminor/glibc.git".insteadOf         "https://sourceware.org/git/glibc.git"
git config --global url."https://github.com/mirror/newlib-cygwin.git".insteadOf  "https://sourceware.org/git/newlib-cygwin.git"

retry() {  # retry <attempts> <cmd...>
    local n=$1; shift
    local i
    for i in $(seq 1 "$n"); do
        "$@" && return 0
        echo "  attempt ${i}/${n} failed: $*"
        sleep 10
    done
    return 1
}

# conda-build will skip init since update=none in .gitmodules
# init submodules here to prevent default beahivor of init-ing everything
retry 3 git submodule update --init --checkout -- riscv-gnu-toolchain

pushd riscv-gnu-toolchain

case "${TOOLCHAIN_GCC}" in
    16) TOOLCHAIN_COMMIT="${TOOLCHAIN_COMMIT:-2e37feb36e1152e965c56d29c0623d68b156c461}" ;;  # tag 2026.07.12
    14) TOOLCHAIN_COMMIT="${TOOLCHAIN_COMMIT:-ec4e967e3bc4ca71de3abb057f776fd8e08f141f}" ;;  # tag 2025.05.01
    *)  echo "ERROR: TOOLCHAIN_GCC must be 14 or 16 (got '${TOOLCHAIN_GCC}')"; exit 1 ;;
esac
echo "Checking out toolchain commit ${TOOLCHAIN_COMMIT}"
retry 3 git fetch origin "${TOOLCHAIN_COMMIT}"
git checkout --detach "${TOOLCHAIN_COMMIT}"
# init only the submodules needed for the newlib(elf)+linux(glibc) toolchains
git submodule sync
for sub in binutils gcc gdb glibc newlib; do
    retry 3 git submodule update --init --recursive --depth 1 "${sub}"
done
popd

# make gcc14 errs warnings for gcc14 targets only
# fixed in gcc16 riscv toolchain
if [ "${TOOLCHAIN_GCC}" = "14" ]; then
    export CFLAGS="${CFLAGS:-} -Wno-error=incompatible-pointer-types"
fi

# run w/ $NPROC - 1 to not crash the machine
_NCPU="${CPU_COUNT:-$(nproc)}"
NPROC=$(( _NCPU > 1 ? _NCPU - 1 : 1 ))
NPROC=$NPROC ./build-toolchains.sh \
    --prefix "$PREFIX/$TOOLCHAIN_NAME" \
    --clean-after-install \
    ${MULTILIB:+--multilib} \
    ${ARCH:+--arch $ARCH} \
    ${ABI:+--abi $ABI}

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
