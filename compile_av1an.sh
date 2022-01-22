#! /bin/bash
# A script to automatically compile av1an because I'm lazy :P
# Drag and drop this script to 'MSYS2 MinGW' to run.

cd /d/Av1an
git pull

pacman -Syu

RUSTFLAGS="-C target-cpu=native" \
cargo build --release

strip target/release/av1an.exe
cp target/release/av1an.exe /d/Programs/av1an/

cargo clean
