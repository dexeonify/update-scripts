Push-Location "D:\Misc\Scripts\Update-Scripts"

$scripts = ".\Update GitHub Releases.ps1", ".\Update Lastrosade Builds.ps1", ".\Sort Binaries.ps1"

foreach ($script in $scripts) {
    $name = $script -replace "\.\\"
    Write-Host "`nRunning $name" -ForegroundColor Cyan
    & $script
}

Pop-Location
