Push-Location "D:\AI"

function Test-IsLatest {
    <#
    .SYNOPSIS
        Test if current version is latest.

    .DESCRIPTION
        Compares installed version to the latest release.
    #>
    if ( Test-Path "$reponame\version.txt" ) {
        $version = Get-Content "$reponame\version.txt"
    }
    else {
        Write-Host "version.txt not found!" -ForegroundColor Red
        return $false
    }

    $latest = $version -match $tag
    if ( $latest -eq $true ) { Write-Host "You are already using the latest version of $reponame!`n" -ForegroundColor Green }
    return $latest
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

function Update-Release {
    <#
    .SYNOPSIS
        Main update function.

    .DESCRIPTION
        Checks version, download and update version.txt.
    #>
    param ($format)

    if ( !(Test-IsLatest) ) {
        Get-LatestRelease $format

        Write-Host "Writing latest tag as record." -ForegroundColor Blue
        Set-Content -Path "$reponame\version.txt" -Value $tag

        Write-Host "$reponame Updated`n" -ForegroundColor Green
    }
}


$repos = "nihui/waifu2x-ncnn-vulkan", "nihui/rife-ncnn-vulkan", "nihui/realsr-ncnn-vulkan", "k4yt3x/video2x"
foreach ($repo in $repos) {
    $releases = "https://api.github.com/repos/$repo/releases"
    $reponame = $repo.Split("/")[1]

    Write-Host "`nDetermining latest release of $reponame" -ForegroundColor Blue
    $tag = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].tag_name
    Write-Host "Latest release: $tag" -ForegroundColor Blue

    # Set format of releases based on repo
    switch -Regex ( $repo ) {
        "nihui"  { Update-Release -format "$reponame-$tag-windows.zip" }
        "k4yt3x" { Update-Release -format "$reponame-$tag-win32-light.zip" }
    }
}

Write-Host "Updating RIFE arXiv2020..." -ForegroundColor Blue
git -C '.\arXiv2020-RIFE' pull
Write-Host "RIFE arXiv2020 Updated" -ForegroundColor Green

Pop-Location
Read-Host -Prompt "Finished updating AI tools"
