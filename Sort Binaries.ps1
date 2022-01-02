Push-Location D:\Programs

$folders = @{
    "video" = ".\Video"
    "audio" = ".\Audio"
    "image" = ".\Image"
    "others" = ".\Others"
    "ffmpeg" = ".\Video\ffmpeg"
}

$categories = @{
    "video" = "aomenc.exe", "av1an.exe", "mediainfo.exe", "rav1e.exe", "SvtAv1EncApp.exe", "vpxenc.exe"
    "audio" = "opusenc.exe", "fdkaac.exe"
    "image" = "avifenc.exe", "avifdec.exe", "cavif.exe", "cjxl.exe", "djxl.exe", "cwebp.exe", "gifski.exe"
    "others" = "aria2c.exe", "croc.exe"
    "ffmpeg" = "ffmpeg.exe", "ffplay.exe", "ffprobe.exe", "avcodec-59.dll", "avdevice-59.dll", "avfilter-8.dll",
               "avformat-59.dll", "avutil-57.dll", "postproc-56.dll", "swresample-4.dll", "swscale-6.dll"
}

Get-ChildItem -Path * -Include "*.exe", "*.dll" | ForEach-Object {
    $file = $_.Name
    try {
        $category = ($categories.GetEnumerator() | Where-Object Value -contains $file).Name
        $folder = $folders.$category
        Write-Host "$file is categorised as $category, moving to $folder." -ForegroundColor Blue
        Move-Item $file -Destination $folder -Force
    }
    catch {
        Write-Warning "$file does not belong in any categories."
    }
}

Pop-Location
Read-Host "Sorted binaries to their respective categories"
