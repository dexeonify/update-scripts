Push-Location "D:\Programs"
$ProgressPreference = 'SilentlyContinue'

function Get-Property ($property) {
    <#
    .SYNOPSIS
        Gets property like archive name and date time from manifest.json
    #>
    $json = Get-Content manifest.json | ConvertFrom-Json
    $files = Select-Object -InputObject $json -ExpandProperty "files"
    Select-Object -InputObject $files -ExpandProperty $program | Select-Object -ExpandProperty $property
}

function Test-IfLatest {
    <#
    .SYNOPSIS
        Test if current version is latest.

    .DESCRIPTION
        Compares timestamps in current version.json to downloaded manifest.json
    #>
    if ( Test-Path version.json ) {
        $version = Get-Content version.json | ConvertFrom-Json
    }
    else {
        Write-Host "version.json not found!" -ForegroundColor Red
        return $false
    }

    $latest = $datetime -eq $version.$program
    if ( $latest -eq $true ) { Write-Host "You are already using the latest version of $filename!`n" -ForegroundColor Green }
    return $latest
}

function Read-KeyOrTimeout ($prompt, $key) {
    $seconds = 9
    $startTime = Get-Date
    $timeOut = New-TimeSpan -Seconds $seconds

    # Flush unwanted buffer prior to ReadKey()
    $HOST.UI.RawUI.Flushinputbuffer()

    Write-Host "$prompt " -ForegroundColor Green

    # Basic progress bar
    [Console]::CursorLeft = 0
    [Console]::Write("[")
    [Console]::CursorLeft = $seconds + 2
    [Console]::Write("]")
    [Console]::CursorLeft = 1

    while (-not [System.Console]::KeyAvailable) {
        $currentTime = Get-Date
        Start-Sleep -s 1
        Write-Host "█" -NoNewline
        if ( $currentTime -gt $startTime + $timeOut ) {
            Break
        }
    }
    if ( [System.Console]::KeyAvailable ) {
        $response = [System.Console]::ReadKey($true).Key
    }
    else {
        $response = $key
    }
    return $response.ToString()

    # Flush again
    $HOST.UI.RawUI.Flushinputbuffer()
}


# Parses manifest.json for version checking
Invoke-WebRequest https://jeremylee.sh/bins/manifest.json -OutFile manifest.json

# Create a custom object to convert to version.json
$object = New-Object -TypeName psobject

# Create urls.txt to append URLs for batch downloads
New-Item urls.txt -Force | Out-Null

$programs = "avifenc.exe", "avifdec.exe", "cjxl.exe", "cwebp.exe", "vpxenc.exe", "rav1e.exe", "SvtAv1EncApp.exe", "mediainfo.exe", "opusenc.exe"
$autoremove = Read-KeyOrTimeout "Do you want to automatically remove downloaded files? [Y/n] (default=Y)" "Y"
Write-Host ""

foreach ($program in $programs) {
    # Get archive name, date time and file name
    $archive = Get-Property "archive"
    $datetime = Get-Property "datetime"
    $filename = $archive.Split(".")[0]

    # Adds URLs of releases into urls.txt, if newer version is available
    if ( !(Test-IfLatest) ) {
        Write-Host "New version found for $filename!" -ForegroundColor Cyan
        Add-Content urls.txt https://jeremylee.sh/bins/$archive
    }

    # Record date time of last downloaded release, and append to $object
    $object | Add-Member -MemberType NoteProperty -Name $program -Value $datetime
}

# Download, extract and remove (if $autoremove is True) downloaded files
Write-Host "Downloading latest releases..." -ForegroundColor Cyan
aria2c --console-log-level warn -i urls.txt

if ( Test-Path *.7z ) {
    Write-Host "Extracting all downloaded archives..." -ForegroundColor Cyan
    7z x -y *.7z | Out-Null

    if ( $autoremove -eq 'Y' ) {
        Write-Host "Removing all downloaded archives" -ForegroundColor Magenta
        Remove-Item *.7z | Out-Null
    }
}

# Remove unused files
$unusedfiles = "manifest.json", "urls.txt", "dwebp.exe", "webpinfo.exe", "webpmux.exe", "jxlinfo.exe",
               "benchmark_xl.exe", "SvtAv1DecApp.exe", "vpxdec.exe", "opusdec.exe", "opusinfo.exe"

Remove-Item $unusedfiles -ErrorAction SilentlyContinue

# Update version.json
$object | ConvertTo-Json | Out-File version.json

Pop-Location
Read-Host -Prompt "Finished updating Lastrosade builds"
