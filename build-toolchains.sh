#!/usr/bin/env bash

#this script is based on the firesim build toolchains script

# exit script if any command fails
set -ex
set -o pipefail

# On macOS, use GNU readlink from 'coreutils' package in Homebrew/MacPorts
if [ "$(uname -s)" = "Darwin" ] ; then
    READLINK=greadlink
else
    READLINK=readlink
fi

# If BASH_SOURCE is undefined, we may be running under zsh, in that case
# provide a zsh-compatible alternative
DIR="$(dirname "$($READLINK -f "${BASH_SOURCE[0]:-${(%):-%x}}")")"

# Allow user to override MAKE
[ -n "${MAKE:+x}" ] || MAKE=$(command -v gnumake || command -v gmake || command -v make)
readonly MAKE

usage() {
    echo "usage: ${0} [OPTIONS]"
    echo ""
    echo "Options"
    echo "   --prefix PREFIX       : Install destination. If unset, defaults to $(pwd)/riscv-tools-install"
    echo "                           or $(pwd)/esp-tools-install"
    echo "   --clean-after-install : Run make clean in calls to module_make and module_build"
    echo "   --arch -a             : Architecture (e.g., rv64gc)"
    echo "   --help -h             : Display this message"
    exit "$1"
}

error() {
    echo "${0##*/}: ${1}" >&2
}
die() {
    error "$1"
    exit "${2:--1}"
}

TOOLCHAIN="riscv-tools"
CLEANAFTERINSTALL=""
RISCV=""
ARCH=""

# getopts does not support long options, and is inflexible
while [ "$1" != "" ];
do
    case $1 in
        -h | --help | help )
            usage 3 ;;
        -p | --prefix )
            shift
            RISCV=$(realpath $1) ;;
        -a | --arch )
            shift
            ARCH=$1 ;;
        --clean-after-install )
            CLEANAFTERINSTALL="true" ;;
        * )
            error "invalid option $1"
            usage 1 ;;
    esac
    shift
done

if [ -z ${CONDA_DEFAULT_ENV+x} ]; then
    error "ERROR: No conda environment detected. Did you activate the conda environment (e.x. 'conda activate chipyard')?"
    exit 1
fi

if [ -z "$RISCV" ] ; then
      INSTALL_DIR="$TOOLCHAIN-install"
      RISCV="$(pwd)/$INSTALL_DIR"
fi

if [ -z "$ARCH" ] ; then
    XLEN=64
elif [[ "$ARCH" =~ ^rv(32|64)((i?m?a?f?d?|g?)c?)$ ]]; then
    XLEN=${BASH_REMATCH[1]}
else
    error "invalid arch $ARCH"
    usage 1
fi

echo "Installing toolchain to $RISCV"

# install risc-v tools
export RISCV="$RISCV"

cd "${DIR}"

SRCDIR="${DIR}"
. ./build-util.sh

MAKE_VER=$("${MAKE}" --version) || true
case ${MAKE_VER} in
    'GNU Make '[4-9]\.*)
        ;;
    'GNU Make '[1-9][0-9])
        ;;
    *)
        die 'obsolete make version; need GNU make 4.x or later'
        ;;
esac

echo '==>  Building GNU/Linux toolchain'
module_build riscv-gnu-toolchain --prefix="${RISCV}" --with-cmodel=medany ${ARCH:+--with-arch=${ARCH}}
module_make riscv-gnu-toolchain linux

echo "Toolchain Build Complete!"
