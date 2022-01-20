# Compile rust-Av1an git on Windows

**Disclaimer:**
I'm not the developer of the project, nor is this the "official" guide.
I'm just documenting the process when I was trying to compile it as well.
The reason I created this guide is because there *were* no public guides on
how to compile Av1an on Windows.

For the sake of simplicity, we will _not_ be using `rustup`. Therefore, Visual
C++ Build tools _does not_ need to be installed. Instead, we will use
[MSYS2](https://www.msys2.org) for a less painful experience. ;)

## Steps to compile

1. Install [VapourSynth](https://github.com/vapoursynth/vapoursynth/releases).
   For this guide, we'll be installing it system-wide. Just leave all the
   options ticked by default.

2. Set up VapourSynth in `PATH`:

   1. Start menu > Edit the system environment variables >
      **Enviromment variables > System variables > New...**

   2. In the dialog, input the following:

      > Variable name: `VAPOURSYNTH_LIB_DIR`
      >
      > Variable value: `C:\Users\<user>\AppData\Local\Programs\VapourSynth\sdk\lib64`

      **Note:**
      Change according to your VS installation path, also replace `<user>` with
      your username. Absolute path seems to be more reliable.

   3. If you want to use `ffms2` or `lsmash` (recommended):

      - Download `ffms2` from [FFMS/ffms2](https://github.com/FFMS/ffms2/releases)
      - Download `lsmash` from [HomeOfAviSynthPlusEvolution/L-SMASH-Works](https://github.com/HomeOfAviSynthPlusEvolution/L-SMASH-Works/releases/)
      - Extract them to `VapourSynth/plugins64`. In my case, it's located in
        `%appdata%\VapourSynth\plugins64`.

3. Install [MSYS2](https://www.msys2.org/).

   1. Open **MSYS2 MSYS** and run `pacman -Syu` to update all of the packages.

   2. Install all of the necessary dependencies:

      ```bash
      pacman -S nasm mingw-w64-x86_64 mingw-w64-x86_64-pkg-config mingw-w64-x86_64-clang mingw-w64-x86_64-ffmpeg
      ```

4. Download ZIP or `git clone https://github.com/master-of-zen/Av1an`.

5. Open **MSYS2 MinGW 64-bit**, `cd Av1an/`

   1. Run `cargo build --release`.

      **Note:** You can append `RUSTFLAGS="-C target-cpu=native"` before the
      `cargo` command for a *slight* performance boost.

   2. Wait for compilation and `av1an.exe` should be in `target/release/`!

6. Download [Gyan's shared release ffmpeg build](https://www.gyan.dev/ffmpeg/builds/packages/ffmpeg-4.4.1-full_build-shared.7z)
   and extract the DLLs to the same folder as `av1an.exe` in `PATH`.

   As of writing, Av1an hasn't been updated to use the latest `ffmpeg` version
   **(v5.0)**, so it still needs the older version of `ffmpeg`, which is **v4.4**.
   That also means it doesn't work with a shared git `ffmpeg` build like
   [BtBN's builds](https://github.com/BtbN/FFmpeg-Builds). :(

## Error Message

> The code execution cannot proceed because avfilter-7.dll was not found.
> Reinstalling the program may fix this problem.

**Note:**
If you are using Powershell, the error message will be silenced. But you know
Av1an isn't working because it doesn't output anything. Use `cmd` to be sure.

### Problem

Av1an might have compiled, but when you try to run it, it complains about
missing DLLs.

### Solution

Provide Av1an with a dynamically linked (also known as "shared") `ffmpeg`.
You can read how to do so at step 6 above. Also, check if the version matches:
if Av1an complains about `avfilter-7.dll`, but you have `avfilter-8.dll`, you
will have to downgrade your `ffmpeg` version to the one Av1an supports.

## Resources

- To further reduce the binary size/optimize Av1an, see <https://github.com/johnthagen/min-sized-rust>.

- MSYS2 have `strip` built-in, you can run `strip av1an.exe` after compilation.

  | Config      | Size    |
  | ----------- | ------- |
  | Default     | 11.5 MB |
  | lto         | 3.83 MB |
  | lto + strip | 3.18 MB |

- If you want to use portable Vapoursynth instead of system-wide Vapoursynth,
  see <https://www.reddit.com/r/AV1/comments/s8151l/how_to_compile_av1an_on_windows_without_breaking>.
