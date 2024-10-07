Add-MpPreference -ExclusionPath "$extpath\BadUSB"
$extractResult = 7z x "$extpath\BadUSB.tar.zst" -o"$extpath\BadUSB"
if ($extractResult -eq 0) {
    Write-Host "Extraction successful." -ForegroundColor Green
} else {
    Write-Host "Extraction failed!" -ForegroundColor Red
    exit 1
}

cd "$extpath\BadUSB"
.\SHA256.ps1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Checksum verification successful." -ForegroundColor Green
} else {
    Write-Host "Checksum verification failed!" -ForegroundColor Red
    exit 1
}
cd ..

$copyToSD = Read-Host "Do you want to copy all files to your SD card? (y/n)"
if ($copyToSD -eq "y") {
    $drives = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }
    $drivesList = $drives | ForEach-Object { "$($_.DeviceID) ($($_.VolumeName))" }
    $sdChoice = Read-Host "Available external devices: `n$drivesList`nWhich one is correct?"

    # Check if selected device is valid
    if ($drives.DeviceID -contains $sdChoice) {
        Copy-Item -Path "$extpath" -Destination "$sdChoice\Flipper" -Recurse
        Write-Host "Files successfully copied to SD card." -ForegroundColor Green

        $defenderExceptionChoice = Read-Host "Do you want to add a Defender exception on just this drive ($sdChoice) or all external drives? (this/all)"
        if ($defenderExceptionChoice -eq "this") {
            Add-MpPreference -ExclusionPath "$sdChoice\Flipper\BadUSB"
            Write-Host "Defender exception added for $sdChoice." -ForegroundColor Green
        } elseif ($defenderExceptionChoice -eq "all") {
            Add-MpPreference -ExclusionPath "*:\Flipper\BadUSB"
            Write-Host "Defender exception added for all external drives." -ForegroundColor Green
        } else {
            Write-Host "No Defender exception added." -ForegroundColor Yellow
        }
    } else {
        Write-Host "No valid SD card selected. Exiting." -ForegroundColor Red
        exit
    }
} else {
    Write-Host "No changes made. Exiting." -ForegroundColor Yellow
    exit
}

Write-Host "All steps completed successfully!" -ForegroundColor Green
