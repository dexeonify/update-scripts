# Compile rust-Av1an git on Windows

**Disclaimer:**
I'm not the developer of the project, nor is this the "official" guide.
I'm just documenting the process when I was trying to compile it as well.
The reason I created this guide is because there's currently no public guides
(not counting Discord, which is hidden) on how to compile on Windows. :P

For the sake of simplicity, we will _not_ be using `rustup`.
Therefore, Visual C++ Build tools _does not_ need to be installed.
Instead, we will use [MSYS2](https://www.msys2.org/) for a
less painful experience. ;)

1. Install [VapourSynth](https://github.com/vapoursynth/vapoursynth/releases)

2. Set up VapourSynth in `PATH`

   1. Start menu > Edit the system environment variables >
      `Enviromment variables` > `System variables` > `New...`

   2. In the dialog, input the following:

      > Variable name: `VAPOURSYNTH_LIB_DIR`
      >
      > Variable value: `C:\Users\<user>\AppData\Local\Programs\VapourSynth\sdk\lib64`

      **Note:**
      Change according to your VS installation path,
      also replace \<user\> with your username.
      Absolute path seems to be more reliable. 🤔

   3. If you want to use `ffms2` or `lsmash` (recommended):

      - Download `ffms2` from [FFMS/ffms2](https://github.com/FFMS/ffms2/releases)
      - Download `lsmash` from [HomeOfAviSynthPlusEvolution/L-SMASH-Works](https://github.com/HomeOfAviSynthPlusEvolution/L-SMASH-Works/releases/)
      - Place them in `VapourSynth/plugins64`.
        In my case, it's located in `%appdata%\VapourSynth\plugins64`

3. Install [MSYS2](https://www.msys2.org/).

   1. Open **MSYS2 MSYS** and run `pacman -Syu`
   2. Install all the necessary dependencies:

      ```bash
      pacman -S nasm mingw-w64-x86_64 mingw-w64-x86_64-pkg-config mingw-w64-x86_64-clang mingw-w64-x86_64-ffmpeg
      ```

4. `git clone` or download ZIP from <https://github.com/master-of-zen/Av1an>.

5. Open **MSYS2 MinGW 64-bit**, `cd Av1an/`

   **[Optional]** You can optimize the binary to make it smaller, [see below](#Reduce-binary-size).

   1. Run `cargo build --release --no-default-features`
   2. Wait for compilation and `av1an.exe` should be in `target/release/`

6. Download [shared ffmpeg build from Gyan](https://www.gyan.dev/ffmpeg/builds/packages/ffmpeg-4.3.2-full_build-shared.7z)
   and place it together with `av1an.exe` in `PATH`.

   For some reason, Av1an needs an older version of shared `ffmpeg`
   (It needs `avfilter-7.dll`, and does not support `avfilter-8.dll`),
   so [BtBN's builds](https://github.com/BtbN/FFmpeg-Builds) can't be used :(

---

Av1an might have compiled, but when you try to run it,
it will complain about missing dlls.

That's because we specified `--no-default-features` when we called `cargo`.
Since [this commit](https://github.com/master-of-zen/Av1an/commit/f52c82f15cfc17a5018174e1e0c8de95a49884b5),
Av1an uses `ffmpeg-next` crate so it can include a statically linked `ffmpeg`.
Unfortunately, the crate doesn't work on Windows because it tries to
use `pkg-config` and other tools which are only available on Linux.

So... we have to provide Av1an with a dynamically linked
(also known as "shared") `ffmpeg`.

---

**Note**:
As of writing this guide, one of the developers have figured out how to build
Av1an with a statically linked `ffmpeg` on Windows, but it's quite difficult.

## Reduce binary size

- Enable LTO in `Cargo.toml`

  ```toml
  [profile.release]
  lto = true
  ```

- MSYS2 have `strip` built-in, you can just run `strip av1an.exe` after compilation

  | Config      | Size    |
  | ----------- | ------- |
  | Default     | 11.5 MB |
  | lto         | 3.83 MB |
  | lto + strip | 3.18 MB |

- You can probably further shrink the size using [upx](https://github.com/upx/upx)

Read more: <https://github.com/johnthagen/min-sized-rust>
