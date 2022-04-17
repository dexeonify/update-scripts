<#
    .SYNOPSIS
    A script to automatically compile av1an because I'm lazy :P
    Now using Visual Studio.

    .LINK
    All prerequisites and installation guide here:
    https://github.com/master-of-zen/Av1an#compilation-on-windows
#>
Push-Location "D:\Av1an"

git pull
cargo rustc --release -- -C target-cpu=skylake
Copy-Item ".\target\release\av1an.exe" "D:\Programs\Video"
cargo clean

Pop-Location
Read-Host -Prompt "Finished compiling Av1an"
