# A script to automatically compile av1an because I'm lazy :P
# Drag and drop this script to 'MSYS2 MinGW' to run.

cd /d/Av1an
git pull

pacman -Syu

CARGO_PROFILE_RELEASE_LTO=fat \
CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1 \
RUSTFLAGS="-C target-cpu=native" \
cargo build --release

strip target/release/av1an.exe
cp target/release/av1an.exe /d/Programs/

cargo clean
