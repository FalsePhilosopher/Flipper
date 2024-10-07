$Url = "https://github.com/FalsePhilosopher/Flipper/releases/latest/download/Flipper.tar.zst"
$SHA256 = "16589eb2002639b88396aad9c4813bd69d4f2fc9390a28d8b8ec4a58afb4342f"
$tempDir = Join-Path $env:TEMP "Flipper"
$extpath = Join-Path $env:USERPROFILE "Downloads\Flipper"
$allOk = $false  # Initialize $allOk

if (-not (Test-Path -Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

aria2c --file-allocation=none --checksum=sha-256=$SHA256 -o "$tempDir\Flipper.tar.zst" "$Url"
if ($LASTEXITCODE -eq 0) {
    7z x "$tempDir\Flipper.tar.zst" -o"$extpath"
    if ($LASTEXITCODE -eq 0) {
        cd "$extpath"
        ./SHA256.ps1
        if ($LASTEXITCODE -eq 0) {
            cd ..
            Remove-Item -Path $tempDir -Recurse -Force
            $allOk = $true
            Write-Host "Cleanup successful" -ForegroundColor Green
        } else {
            Write-Host "SHA256 check failed. Cleanup will not proceed, decompress the archive again or redownload the archive." -ForegroundColor Red
        }
    } else {
        Write-Host "Extraction failed. Please check the downloaded file." -ForegroundColor Red
    }
} else {
    Write-Host "Download failed. Please check the URL or your network connection." -ForegroundColor Red
    exit 1
}

$makeDefenderException = (Read-Host "Some BadUSB files are flagged as malware. Do you want to make a Defender exception for the BadUSB folder and extract it? (y/n)").Trim()
if ($makeDefenderException -ieq "y") {
    ./$extpath/BadUSB.ps1
    if ($LASTEXITCODE -eq 0) {
        $allOk = $allOk -and $true
    } else {
        Write-Host "Something went wrong with the BadUSB script." -ForegroundColor Red
        $allOk = $false
    }
}

if ($allOk) {
    Write-Host "ALL OK" -ForegroundColor Green
} else {
    Write-Host "Something went wrong" -ForegroundColor Red
}
