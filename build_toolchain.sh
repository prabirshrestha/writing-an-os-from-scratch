#!/bin/sh

echo "===================================================================="
echo "I will try to fetch and build everything needed for a freestanding"
echo "cross-compiler toolchain. This includes binutils, gcc, llvm, clang"
echo "and may take quite a while to build. Play some tetris and check back"
echo "every once in a while. The process is largely automatic and should"
echo "not require any manual intervention. Fingers crossed!"
echo
echo "You'll need UNIX tools make, curl and tar."
echo "===================================================================="
echo

# *** USER-ADJUSTABLE SETTINGS ***

export LLVM_TARGETS=x86
export MAKE_THREADS=8

export LLVM_REVISION=159915
export CLANG_REVISION=159915
# compiler_rt version bumped because of fatal asan warnings.
# version is upped until the warnings disappeared but before it started insisting on ios library generation.
# r159142
export COMPILER_RT_REVISION=159915
export LIBCXX_REVISION=159915

# binutils 2.21 won't work, see https://trac.macports.org/ticket/22679
# minimal binutils version for gcc 4.6.2 is 2.20.1 (.cfi_section support)
BINUTILS_VER=2.22
GCC_VER=4.7.1
MPFR_VER=3.1.1
MPC_VER=0.9
GMP_VER=5.0.5

# END OF USER-ADJUSTABLE SETTINGS

mkdir -p toolchain/build/llvm
mkdir -p toolchain/build/gcc
mkdir -p toolchain/build/binutils
mkdir -p toolchain/build/gmp
mkdir -p toolchain/build/mpfr
mkdir -p toolchain/build/mpc
mkdir -p toolchain/tarballs
mkdir -p toolchain/sources

cd toolchain/

export TOOLCHAIN_DIR=`pwd`
export SOURCE_PREFIX=$TOOLCHAIN_DIR/tarballs

export PREFIX=$TOOLCHAIN_DIR/gcc
export TARGET=i686-pc-elf

export LD=/usr/bin/ld # not /usr/bin/gcc-4.2!!

echo "===================================================================="
echo "Fetching binutils $BINUTILS_VER..."
echo "===================================================================="
if [ ! -f ${SOURCE_PREFIX}/binutils-${BINUTILS_VER}.tar.bz2 ]; then
    echo "binutils"
    curl http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.bz2 -o ${SOURCE_PREFIX}/binutils-${BINUTILS_VER}.tar.bz2
else
    echo "Not fetching binutils, file exists."
fi

echo "===================================================================="
echo "Fetching gcc $GCC_VER..."
echo "===================================================================="

if [ ! -f ${SOURCE_PREFIX}/gcc-${GCC_VER}.tar.bz2 ]; then
    echo "gcc-core"
    curl http://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.bz2 -o ${SOURCE_PREFIX}/gcc-${GCC_VER}.tar.bz2
else
    echo "Not fetching gcc-core, file exists."
fi

echo "===================================================================="
echo "Fetching gcc libraries..."
echo "===================================================================="

if [ ! -f ${SOURCE_PREFIX}/mpfr-${MPFR_VER}.tar.bz2 ]; then
    echo "mpfr"
    curl http://ftp.gnu.org/gnu/mpfr/mpfr-${MPFR_VER}.tar.bz2 -o ${SOURCE_PREFIX}/mpfr-${MPFR_VER}.tar.bz2
else
    echo "Not fetching mpfr, file exists."
fi

if [ ! -f ${SOURCE_PREFIX}/mpc-${MPC_VER}.tar.gz ]; then
    echo "mpc"
    curl http://www.multiprecision.org/mpc/download/mpc-${MPC_VER}.tar.gz -o ${SOURCE_PREFIX}/mpc-${MPC_VER}.tar.gz
else
    echo "Not fetching mpc, file exists."
fi

if [ ! -f ${SOURCE_PREFIX}/gmp-${GMP_VER}.tar.bz2 ]; then
    echo "gmp"
    curl http://ftp.gnu.org/gnu/gmp/gmp-${GMP_VER}.tar.bz2 -o ${SOURCE_PREFIX}/gmp-${GMP_VER}.tar.bz2
else
    echo "Not fetching gmp, file exists."
fi

echo "===================================================================="
echo "Augmenting PATH with local binutils..."
echo "===================================================================="
# Clean also your $PATH as much as possible:
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:$PREFIX/bin

echo "===================================================================="
echo "Extracting binutils $BINUTILS_VER..."
echo "===================================================================="

if [ ! -d sources/binutils-${BINUTILS_VER} ]; then
    tar xf ${SOURCE_PREFIX}/binutils-${BINUTILS_VER}.tar.bz2 -C sources
fi

BINUTILS_VER=`echo $BINUTILS_VER | sed s/[a-z]//g`

echo "===================================================================="
echo "Configuring binutils $BINUTILS_VER..."
echo "===================================================================="


if [ ! -f build/binutils/.config.succeeded ]; then
    cd build/binutils && \
    ../../sources/binutils-${BINUTILS_VER}/configure --prefix=$PREFIX --target=$TARGET --program-prefix=$TARGET- \
    --disable-werror \
    --enable-gold --enable-plugins \
    --disable-nls --disable-shared --disable-multilib && \
    touch .config.succeeded && \
    cd ../.. || exit 1
else
    echo "build/binutils/.config.succeeded exists, NOT reconfiguring binutils!"
fi

echo "===================================================================="
echo "Building binutils $BINUTILS_VER..."
echo "===================================================================="

# To do: add this to build llvm gold plugin and use gold ...
# time make -j$MAKE_THREADS all-gold && \

if [ ! -f build/binutils/.build.succeeded ]; then
    cd build/binutils && \
    time make -j$MAKE_THREADS && \
    touch .build.succeeded && \
    cd ../.. || exit 1
else
    echo "build/binutils/.build.succeeded exists, NOT rebuilding binutils!"
fi

echo "===================================================================="
echo "Installing binutils $BINUTILS_VER..."
echo "===================================================================="

if [ ! -f build/binutils/.install.succeeded ]; then
    cd build/binutils && \
    make install && \
    touch .install.succeeded && \
    cd ../.. || exit 1
else
    echo "build/binutils/.install.succeeded exists, NOT reinstalling binutils!"
fi

export STRIP_FOR_TARGET=$PREFIX/bin/$TARGET-strip

echo "===================================================================="
echo "Extracting gmp $GMP_VER..."
echo "===================================================================="

if [ ! -d sources/gmp-${GMP_VER} ]; then
    tar xf ${SOURCE_PREFIX}/gmp-${GMP_VER}.tar.bz2 -C sources
fi

echo "===================================================================="
echo "Configuring gmp $GMP_VER..."
echo "===================================================================="

# --build=$TARGET --program-prefix=$TARGET-

if [ ! -f build/gmp/.config.succeeded ]; then
    cd build/gmp && \
    ../../sources/gmp-${GMP_VER}/configure --prefix=$PREFIX \
    --enable-cxx --disable-shared && \
    touch .config.succeeded && \
    cd ../.. || exit 1
else
    echo "build/gmp/.config.succeeded exists, NOT reconfiguring gmp!"
fi

echo "===================================================================="
echo "Building gmp $GMP_VER..."
echo "===================================================================="

if [ ! -f build/gmp/.build.succeeded ]; then
    cd build/gmp && \
    make -j$MAKE_THREADS && \
    make check && \
    touch .build.succeeded && \
    cd ../.. || exit 1
else
    echo "build/gmp/.build.succeeded exists, NOT rebuilding gmp!"
fi

echo "===================================================================="
echo "Installing gmp $GMP_VER..."
echo "===================================================================="

if [ ! -f build/gmp/.install.succeeded ]; then
    cd build/gmp && \
    make install && \
    touch .install.succeeded && \
    cd ../.. || exit 1
else
    echo "build/gmp/.install.succeeded exists, NOT reinstalling gmp!"
fi

echo "===================================================================="
echo "Extracting mpfr $MPFR_VER..."
echo "===================================================================="

if [ ! -d sources/mpfr-${MPFR_VER} ]; then
    tar xf ${SOURCE_PREFIX}/mpfr-${MPFR_VER}.tar.bz2 -C sources
fi

echo "===================================================================="
echo "Configuring mpfr $MPFR_VER..."
echo "===================================================================="

if [ ! -f build/mpfr/.config.succeeded ]; then
    cd build/mpfr && \
    ../../sources/mpfr-${MPFR_VER}/configure --prefix=$PREFIX --with-gmp=$PREFIX --disable-shared && \
    touch .config.succeeded && \
    cd ../.. || exit 1
else
    echo "build/mpfr/.config.succeeded exists, NOT reconfiguring mpfr!"
fi

echo "===================================================================="
echo "Building mpfr $MPFR_VER..."
echo "===================================================================="

if [ ! -f build/mpfr/.build.succeeded ]; then
    cd build/mpfr && \
    make -j$MAKE_THREADS && \
    touch .build.succeeded && \
    cd ../.. || exit 1
else
    echo "build/mpfr/.build.succeeded exists, NOT rebuilding mpfr!"
fi

echo "===================================================================="
echo "Installing mpfr $MPFR_VER..."
echo "===================================================================="

if [ ! -f build/mpfr/.install.succeeded ]; then
    cd build/mpfr && \
    make install && \
    touch .install.succeeded && \
    cd ../.. || exit 1
else
    echo "build/mpfr/.install.succeeded exists, NOT reinstalling mpfr!"
fi

echo "===================================================================="
echo "Extracting mpc $MPC_VER..."
echo "===================================================================="

if [ ! -d sources/mpc-${MPC_VER} ]; then
    tar xf ${SOURCE_PREFIX}/mpc-${MPC_VER}.tar.gz -C sources
fi

echo "===================================================================="
echo "Configuring mpc $MPC_VER..."
echo "===================================================================="

if [ ! -f build/mpc/.config.succeeded ]; then
    cd build/mpc && \
    ../../sources/mpc-${MPC_VER}/configure --prefix=$PREFIX --with-gmp=$PREFIX --with-mpfr=$PREFIX --disable-shared && \
    touch .config.succeeded && \
    cd ../.. || exit 1
else
    echo "build/mpc/.config.succeeded exists, NOT reconfiguring mpc!"
fi

echo "===================================================================="
echo "Building mpc $MPC_VER..."
echo "===================================================================="

if [ ! -f build/mpc/.build.succeeded ]; then
    cd build/mpc && \
    make -j$MAKE_THREADS && \
    touch .build.succeeded && \
    cd ../.. || exit 1
else
    echo "build/mpc/.build.succeeded exists, NOT rebuilding mpc!"
fi

echo "===================================================================="
echo "Installing mpc $MPC_VER..."
echo "===================================================================="

if [ ! -f build/mpc/.install.succeeded ]; then
    cd build/mpc && \
    make install && \
    touch .install.succeeded && \
    cd ../.. || exit 1
else
    echo "build/mpc/.install.succeeded exists, NOT reinstalling mpc!"
fi

echo "===================================================================="
echo "Extracting gcc $GCC_VER..."
echo "===================================================================="

if [ ! -d sources/gcc-${GCC_VER} ]; then
    tar xf ${SOURCE_PREFIX}/gcc-${GCC_VER}.tar.bz2 -C sources
fi

echo "===================================================================="
echo "Configuring gcc $GCC_VER..."
echo "===================================================================="

# Enabling c++ language as we need g++ driver too...

if [ ! -f build/gcc/.config.succeeded ]; then
    cd build/gcc && \
    ../../sources/gcc-${GCC_VER}/configure --prefix=$PREFIX --target=$TARGET --program-prefix=$TARGET- \
    --with-gmp=$PREFIX \
    --with-mpfr=$PREFIX \
    --with-mpc=$PREFIX \
    --with-system-zlib --enable-stage1-checking \
    --enable-languages=c,c++ \
    --disable-nls --disable-shared --disable-multilib \
    && \
    touch .config.succeeded && \
    cd ../.. || exit 1
else
    echo "build/gcc/.config.succeeded exists, NOT reconfiguring gcc!"
fi

echo "===================================================================="
echo "Building gcc $GCC_VER..."
echo "===================================================================="

if [ ! -f build/gcc/.build.succeeded ]; then
    cd build/gcc && \
    make -j$MAKE_THREADS all-gcc && \
    make -j$MAKE_THREADS all-target-libgcc && \
    touch .build.succeeded && \
    cd ../.. || exit 1
else
    echo "build-gcc/.build.succeeded exists, NOT rebuilding gcc!"
fi

echo "===================================================================="
echo "Installing gcc $GCC_VER..."
echo "===================================================================="

if [ ! -f build/gcc/.install.succeeded ]; then
    cd build/gcc && \
    make install-gcc && \
    make install-target-libgcc && \
    touch .install.succeeded && \
    cd ../.. || exit 1
else
    echo "build/gcc/.install.succeeded exists, NOT reinstalling gcc!"
fi

echo "===================================================================="
echo "To clean up:"
echo "cd toolchain"
echo "rm -rf tarballs build sources"
echo
echo "Toolchain binaries will remain in gcc/"
echo "where Metta configure will find them."
echo "===================================================================="
echo
echo "===================================================================="
echo "===================================================================="
echo "All done, enjoy!"
echo "===================================================================="
echo "===================================================================="
cd ..

