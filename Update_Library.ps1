# Move repository contents to LTspice library
# This script copies all folders in the repository (except .git) to the LTspice library location

# Define source and destination paths
$repoPath = $PSScriptRoot
$repoName = "WØUNC-LTSpice-Library"
$destinationPath = "$env:APPDATA\..\Local\LTspice\lib\sym\$repoName"

# Create destination directory if it doesn't exist
if (-not (Test-Path -Path $destinationPath)) {
    New-Item -Path $destinationPath -ItemType Directory -Force
    Write-Host "Created destination directory: $destinationPath"
}

# Get all directories in the repository (except .git)
$directories = Get-ChildItem -Path $repoPath -Directory | Where-Object { $_.Name -ne ".git" }

# Process each directory
foreach ($dir in $directories) {
    Write-Host "Processing directory: $($dir.Name)"
    
    # Get all items in this directory
    $items = Get-ChildItem -Path $dir.FullName -Recurse
    
    # Copy each item to destination, preserving directory structure relative to the source folder
    foreach ($item in $items) {
        $relativePath = $item.FullName.Substring($dir.FullName.Length)
        $targetPath = Join-Path -Path $destinationPath -ChildPath $relativePath
        
        # Create directory if it doesn't exist
        if ($item.PSIsContainer) {
            if (-not (Test-Path -Path $targetPath)) {
                New-Item -Path $targetPath -ItemType Directory -Force | Out-Null
            }
        }
        # Copy file
        else {
            $targetDir = Split-Path -Path $targetPath -Parent
            if (-not (Test-Path -Path $targetDir)) {
                New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
            }
            Copy-Item -Path $item.FullName -Destination $targetPath -Force
        }
    }
}

Write-Host "Completed moving repository contents to: $destinationPath"
Write-Host "To use these components in LTspice, restart LTspice if it's currently running." 