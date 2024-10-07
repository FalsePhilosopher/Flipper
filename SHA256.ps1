# Get the current directory (where the script is executed from)
$directoryPath = (Get-Location).Path

# Hash file path (assuming it's named "SHA256" and located in the same directory as the script)
$hashFilePath = Join-Path $directoryPath "SHA256"

# Function to compute SHA256 hash for a file
function Get-SHA256Hash($file) {
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $stream = [System.IO.File]::OpenRead($file)
    $hash = [BitConverter]::ToString($sha256.ComputeHash($stream)).Replace("-", "").ToLower()
    $stream.Close()
    return $hash
}

# Check if the hash file exists
if (-Not (Test-Path $hashFilePath)) {
    Write-Host "Hash file 'SHA256' not found in $directoryPath."
    exit
}

# Load the hash file, assuming it contains lines with the format: "<hash> <filename>"
$hashDictionary = @{}
Get-Content $hashFilePath | ForEach-Object {
    # Split each line into hash and filename
    $lineParts = $_ -split ' ', 2
    if ($lineParts.Length -eq 2) {
        $hash = $lineParts[0].Trim()
        $file = $lineParts[1].Trim()
        $hashDictionary[$file] = $hash
    }
}

# Recursively get all files in the current directory
Get-ChildItem -Path $directoryPath -File -Recurse | ForEach-Object {
    $filePath = $_.FullName
    $relativeFilePath = $_.FullName.Substring($directoryPath.Length + 1) # Get file path relative to the current directory

    if ($hashDictionary.ContainsKey($relativeFilePath)) {
        $expectedSHA256 = $hashDictionary[$relativeFilePath]
        $sha256Hash = Get-SHA256Hash $filePath

        if ($sha256Hash -eq $expectedSHA256) {
            Write-Host "File '$relativeFilePath' is authentic."
        } else {
            Write-Host "File '$relativeFilePath' may have been tampered with!"
            Write-Host "SHA256 Hash: $sha256Hash"
        }
    } else {
        Write-Host "No hash entry found for file '$relativeFilePath' in the hash file."
    }
}

echo "All Ok" || echo "Something's fishy"
