#! /bin/bash
# A script to automatically cross compile aomenc for Windows
# with compiler optimizations such as march=skylake, O3 and LTO!
# Tested on WSL Ubuntu.
#
# If you wish to learn more what each option does:
# https://www.reddit.com/r/AV1/comments/jmwepw/how_to_build_libaomav1_to_be_as_fast_as_possible/
#
# === Prerequisites === #
# sudo apt install cmake make nasm gcc-mingw-w64 g++-mingw-w64

export CFLAGS="-flto -O3 -march=skylake" CXXFLAGS="-flto -O3 -march=skylake" LDFLAGS="-flto -O3 -march=skylake"

git clone -b full_build-alpha-4 https://github.com/BlueSwordM/aom-av1-psy

cd aom-av1-psy

cmake -B build-mingw-w64 \
-DCMAKE_BUILD_TYPE=Release \
-DBUILD_SHARED_LIBS=0 \
-DENABLE_DOCS=0 \
-DENABLE_TESTS=0 \
-DCONFIG_AV1_DECODER=0 \
-DCMAKE_C_FLAGS_INIT="-flto=8 -static" \
-DCMAKE_EXE_LINKER_FLAGS="-flto -static" \
-DCMAKE_CXX_FLAGS="-flto -O3 -march=skylake" \
-DCMAKE_C_FLAGS="-flto -O3 -march=skylake" \
-DCMAKE_TOOLCHAIN_FILE=~/aom-av1-psy/build/cmake/toolchains/x86_64-mingw-gcc.cmake

make -C build-mingw-w64 -j$(nproc)

cp build-mingw-w64/aomenc.exe /mnt/d/Programs/Video/

rm -rf ../aom-av1-psy
