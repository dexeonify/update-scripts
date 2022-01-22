Push-Location "D:\Misc\Scripts\Update-Scripts"

$scripts = ".\Update-GitHubReleases.ps1", ".\Update-LastrosadeBuilds.ps1", ".\Sort-Binaries.ps1"

foreach ($script in $scripts) {
    $name = $script -replace "\.\\"
    Write-Host "`nRunning $name" -ForegroundColor Cyan
    & $script
}

Pop-Location
