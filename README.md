# update-scripts

Some personal Powershell scripts to update CLI programs from GitHub
and Windows builds from <https://jeremylee.sh/bins>.
Also includes some scripts to compile programs.

## GitHub Releases

- [aria2/aria2](https://github.com/aria2/aria2)
- [schollz/croc](https://github.com/schollz/croc)
- [ImageOptim/gifski](https://github.com/ImageOptim/gifski)
- [BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds)
- [kornelski/cavif-rs](https://github.com/kornelski/cavif-rs/)

## Windows Builds

- avifenc.exe
- avifdec.exe
- cjxl.exe
- djxl.exe
- cwebp.exe
- vpxenc.exe
- rav1e.exe
- SvtAv1EncApp.exe
- mediainfo.exe
- opusenc.exe

## Others

- `Compile aomenc.sh`:
  Cross compile [aomenc](https://aomedia.googlesource.com/aom/) with
  several compiler optimizations (such as **march=skylake + O3 + LTO**).

- [Compile av1an.md](Compile%20av1an.md):
  An (unofficial) guide to compile
  [Av1an](https://github.com/master-of-zen/Av1an) on Windows.

- `Compile av1an.sh`: Drag and drop script to compile Av1an.
- `Sort Binaries.ps1`: Sort downloaded binaries into their respective folders.
