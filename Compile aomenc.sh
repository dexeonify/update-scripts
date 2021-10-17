#! /bin/bash
# A script to automatically cross compile aomenc for Windows
# with compiler optimizations such as march=skylake + LTO!

export CC=/usr/bin/gcc-10 CXX=/usr/bin/g++-10 CFLAGS="-flto -O3 -march=skylake" CXXFLAGS="-flto -O3 -march=skylake" LDFLAGS="-flto -O3 -march=skylake"

git clone https://aomedia.googlesource.com/aom

cd aom

cmake -B build-mingw-w64 \
-DCMAKE_BUILD_TYPE=Release \
-DBUILD_SHARED_LIBS=0 \
-DENABLE_DOCS=0 \
-DENABLE_TESTS=0 \
-DCONFIG_AV1_DECODER=0 \
-DCMAKE_C_FLAGS_INIT="-flto=8 -static -static-libgcc" \
-DCMAKE_EXE_LINKER_FLAGS="-flto -static -static-libgcc" \
-DCMAKE_CXX_FLAGS="-flto -O3 -march=skylake" \
-DCMAKE_C_FLAGS="-flto -O3 -march=skylake" \
-DCMAKE_TOOLCHAIN_FILE=/home/squrtxair/aom/build/cmake/toolchains/x86_64-mingw-gcc.cmake

make -C build-mingw-w64 -j$(nproc)

croc send --code new-aomenc build-mingw-w64/aomenc.exe

rm -rf ../aom
