Push-Location "D:\Programs"

function Set-CustomTag {
    <#
    .SYNOPSIS
        Creates a custom tag that is derived from the release tag.

    .DESCRIPTION
        Usually, the same tag is used to name the version of releases.
        Eg: If the tag is 'v4.0.3', the release format would be 'release-v4.0.3.zip'

        But, some GitHub repos uses a different tag (but still derived from the original tag)
        for their release files.
        Eg: The tag is 'v9.4.2', but the release format is 'release-9.4.2.zip'.
    #>
    param ($replace)

    Set-Variable -Name "customtag" -Value $( $tag -replace $replace ) -Scope global
}

function Test-NeedUpdate {
    <#
    .SYNOPSIS
        Checks for the latest version of release and decide if updating is needed.

    .DESCRIPTION
        Compares the current version of the program to the latest version on GitHub.
        Returns True or False for $needupdate.

    .PARAMETER arg
        Specify the command line arguments to output the version of the program.

    .PARAMETER tagtype
        Determine whether to compare to the original tag or custom tag.
        Some GitHub repos uses a different tag, which might not match the program's output.
        Eg: aria2c --version prints "version 1.36.0",
            while the GitHub repo uses "release-1.36.0" as its tag.
    #>
    param ($arg, $tagtype)

    $needupdate = (Invoke-Expression $arg | Out-String) -notmatch $tagtype
    return $needupdate
}

function Get-LatestRelease {
    <#
    .SYNOPSIS
        Downloads the latest release based on the naming format.
    #>
    param ($format)

    $script:archive = $format
    Write-Host "Dowloading latest release of $reponame..." -ForegroundColor Green
    $download = "https://github.com/$repo/releases/download/$tag/$format"
    aria2c --console-log-level warn $download
}

function Expand-Release {
    <#
    .SYNOPSIS
        Invoke 7-zip to extract and filter the specific file.
    #>
    param ($file, $filter)

    Write-Host "Extracting $file" -ForegroundColor Green
    7z e -y $file $filter | Out-Null
}

function Remove-Release {
    <#
    .SYNOPSIS
        Removes file, if $autoremove is True.
    #>
    param ($file)

    if ($autoremove -eq 'Y') {
        Write-Host "Removing $file archive" -ForegroundColor Magenta
        Remove-Item $file | Out-Null
    }
}

function Update-Release {
    <#
    .SYNOPSIS
        Main update function which accepts all the parameters.

    .DESCRIPTION
        Groups all the above updating functions into one main function
        and accept all parameters needed for each function.
    #>
    param ($arg, $tagtype, $format, $filter)

    $needupdate = Test-NeedUpdate -arg $arg -tagtype $tagtype
    if ( $needupdate -eq $true ) {
        Get-LatestRelease -format $format
        Write-Host "$reponame Updated`n" -ForegroundColor Green
        Expand-Release -file $archive -filter $filter
        Remove-Release -file $archive
    }
    else {
        Write-Host "You are already using the latest version.`n" -ForegroundColor Green
    }
}

function Update-Gifski {
    <#
    .SYNOPSIS
        A specialised function to update Gifski.

    .DESCRIPTION
        Gifski uses a different archive method: tar.xz. Due to this, we would
        have to use a different method to extract Gifski with 7-zip.
    #>
    $needupdate = Test-NeedUpdate -arg "gifski --version" -tagtype $tag

    if ($needupdate) {
        Get-LatestRelease -format "gifski-$tag.tar.xz"
        cmd /c "7z x $archive -so | 7z e -aoa -si -ttar win/gifski.exe" | Out-Null
        Remove-Release -file $archive
    }
    else {
        Write-Host "You are already using the latest version.`n" -ForegroundColor Green
    }
}

function Update-FFmpeg {
    <#
    .SYNOPSIS
        A specialised function to update FFmpeg.

    .DESCRIPTION
        We've have switched from Gyan's FFmpeg to BtbN's, so we can have both git
        and shared builds. Unfortunately, BtbN's release tag isn't very helpful, as
        it can't be used to compare versions, nor can it be used to form the download
        URL. Therefore, we have to use a different code path for both version checking
        and downloading latest release.
    #>
    # Get the download URL and archive name
    $urls = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].assets.browser_download_url
    $download = ($urls | Select-String "win64-gpl-shared.zip" -NoEmphasis)
    $archive = (Split-Path $download -Leaf)

    # Extract the version from the download URL using regex
    $download -match "ffmpeg-(N.+?(?=-win64))" | Out-Null
    Set-Variable -Name "customtag" -Value $Matches[1] -Scope global
    $needupdate = Test-NeedUpdate -arg "ffmpeg -version" -tagtype $customtag

    if ($needupdate) {
        Write-Host "Dowloading latest release of ffmpeg..." -ForegroundColor Green
        aria2c --console-log-level warn $download
        Write-Host "$reponame Updated`n" -ForegroundColor Green
        Expand-Release -file $archive -filter @("*\bin\*.exe", "*\bin\*.dll")
        Remove-Release -file $archive
        Invoke-Item .
    }
    else {
        Write-Host "You are already using the latest version.`n" -ForegroundColor Green
    }
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
        if ($currentTime -gt $startTime + $timeOut) {
            Break
        }
    }
    if ([System.Console]::KeyAvailable) {
        $response = [System.Console]::ReadKey($true).Key
    }
    else {
        $response = $key
    }
    return $response.ToString()

    # Flush again
    $HOST.UI.RawUI.Flushinputbuffer()
}


$repos = "aria2/aria2", "schollz/croc", "ImageOptim/gifski", "BtbN/FFmpeg-Builds"
$autoremove = Read-KeyOrTimeout "Do you want to automatically remove downloaded packages? [Y/n] (default=Y)" "Y"
Write-Host ""

foreach ($repo in $repos) {
    $releases = "https://api.github.com/repos/$repo/releases"
    $reponame = $repo.Split("/")[1]

    Write-Host "`nDetermining latest release of $reponame" -ForegroundColor Blue
    $tag = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].tag_name
    Write-Host "Latest release: $tag" -ForegroundColor Blue

    switch ( $reponame ) {
        "aria2" {
            Set-CustomTag ".*-"
            Update-Release -arg "aria2c --version" -tagtype $customtag `
                           -format "aria2-$customtag-win-64bit-build1.zip" -filter "*\aria2c.exe"
        }
        "croc" {
            Set-CustomTag ".*v"
            Update-Release -arg "croc --version" -tagtype $customtag `
                           -format "croc_$customtag`_Windows-64bit.zip" -filter "croc.exe"
        }
        "gifski"        { Update-Gifski }
        "FFmpeg-Builds" { Update-FFmpeg }
    }
}

Pop-Location
Read-Host -Prompt "Finished updating GitHub releases"
