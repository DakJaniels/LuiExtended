# Script to find unused media files in LuiMedia
# Scans codebase for references to media constants and paths

param(
    [string]$MediaPath = "LuiMedia\media",
    [string]$MediaPathsFile = "LuiMedia\MediaPaths.lua",
    [string]$CodebasePath = ".",
    [switch]$IncludeXml = $false,
    [string]$OutputFile = "unused_media.txt"
)

Write-Host "Finding unused media files..." -ForegroundColor Cyan
Write-Host ""

# Get all media files
if (-not (Test-Path $MediaPath)) {
    Write-Host "Error: Media path not found: $MediaPath" -ForegroundColor Red
    exit 1
}

$mediaFiles = Get-ChildItem -Path $MediaPath -Recurse -File | Where-Object { $_.Extension -in @('.dds', '.slug') } | Sort-Object FullName
Write-Host "Found $($mediaFiles.Count) media files" -ForegroundColor Cyan

# Read MediaPaths.lua and extract constants
if (-not (Test-Path $MediaPathsFile)) {
    Write-Host "Error: MediaPaths.lua not found: $MediaPathsFile" -ForegroundColor Red
    exit 1
}

Write-Host "Reading constants from MediaPaths.lua..." -ForegroundColor Cyan
$mediaPathsContent = Get-Content $MediaPathsFile -Raw

# Map: file path -> constant name
$pathToConstant = @{}
# Map: constant name -> file path
$constantToPath = @{}
# Map: file path -> file info
$filePathMap = @{}

# Parse constants from MediaPaths.lua
# Pattern: LUIE_MEDIA_... = "LuiMedia/media/..."
$pattern = 'LUIE_MEDIA_\w+\s*=\s*"([^"]+)"'
$regexMatches = [regex]::Matches($mediaPathsContent, $pattern)

foreach ($match in $regexMatches) {
    $fullMatch = $match.Groups[0].Value
    $constantName = $fullMatch -replace '\s*=\s*"[^"]+"', ''
    $path = $match.Groups[1].Value
    
    # Normalize path
    $normalizedPath = $path -replace '\\', '/'
    
    $constantToPath[$constantName] = $normalizedPath
    $pathToConstant[$normalizedPath] = $constantName
    
    # Also map old LuiExtended paths
    $oldPath = $normalizedPath -replace '^LuiMedia/', 'LuiExtended/'
    if ($oldPath -ne $normalizedPath) {
        $pathToConstant[$oldPath] = $constantName
    }
}

Write-Host "Found $($constantToPath.Count) media constants" -ForegroundColor Cyan

# Build file path map (normalized paths)
$mediaPathResolved = (Resolve-Path $MediaPath).Path
foreach ($file in $mediaFiles) {
    $relativePath = $file.FullName -replace [regex]::Escape($mediaPathResolved + "\"), ""
    $normalizedPath = "LuiMedia/media/" + ($relativePath -replace "\\", "/")
    $filePathMap[$normalizedPath] = $file
}

# Get all code files to search (includes LuiExtended, LuiData, and other directories)
$searchExtensions = if ($IncludeXml) { @('*.lua', '*.xml') } else { @('*.lua') }

$codeFiles = Get-ChildItem -Path $CodebasePath -Recurse -Include $searchExtensions -File | 
Where-Object { 
    $_.FullName -notmatch '\\LuiMedia\\media\\' -and
    $_.FullName -notmatch '\\MediaPaths\.lua$' -and
    $_.FullName -notmatch '\\generate_media_paths\.ps1$' -and
    $_.FullName -notmatch '\\replace_media_paths\.ps1$' -and
    $_.FullName -notmatch '\\find_unused_media\.ps1$'
}

$luiExtendedFiles = ($codeFiles | Where-Object { $_.FullName -match '\\LuiExtended\\' }).Count
$luiDataFiles = ($codeFiles | Where-Object { $_.FullName -match '\\LuiData\\' }).Count
$otherFiles = $codeFiles.Count - $luiExtendedFiles - $luiDataFiles

Write-Host "Searching $($codeFiles.Count) code files for references..." -ForegroundColor Cyan
Write-Host "  LuiExtended: $luiExtendedFiles files" -ForegroundColor Gray
Write-Host "  LuiData: $luiDataFiles files" -ForegroundColor Gray
if ($otherFiles -gt 0) {
    Write-Host "  Other: $otherFiles files" -ForegroundColor Gray
}
Write-Host ""

# Track which files are used
$usedFiles = @{}
$unusedFiles = @{}

# Combine all code file contents for efficient searching
Write-Host "Loading code file contents..." -ForegroundColor Cyan
$combinedContent = ""
$fileContents = @{}
foreach ($file in $codeFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content) {
        $fileContents[$file.FullName] = $content
        $combinedContent += $content + "`n"
    }
}
Write-Host "Loaded $($fileContents.Count) files ($([math]::Round($combinedContent.Length / 1MB, 2)) MB)" -ForegroundColor Cyan
Write-Host ""

# Search for references (optimized: search combined content once per media file)
Write-Host "Searching for media references..." -ForegroundColor Cyan
$processed = 0
foreach ($normalizedPath in $filePathMap.Keys) {
    $processed++
    if ($processed % 100 -eq 0) {
        Write-Host "  Processed $processed / $($filePathMap.Count) files..." -ForegroundColor Gray
    }
    
    if ($usedFiles.ContainsKey($normalizedPath)) { continue }
    
    $constantName = $pathToConstant[$normalizedPath]
    $relativePathOnly = $normalizedPath -replace '^LuiMedia/media/', ''
    
    # Check for constant reference
    if ($constantName -and $combinedContent -match [regex]::Escape($constantName)) {
        $usedFiles[$normalizedPath] = $true
        continue
    }
    
    # Check for direct path reference (normalized)
    if ($combinedContent -match [regex]::Escape($normalizedPath)) {
        $usedFiles[$normalizedPath] = $true
        continue
    }
    
    # Check for old path reference
    $oldPath = $normalizedPath -replace '^LuiMedia/', 'LuiExtended/'
    if ($oldPath -ne $normalizedPath -and $combinedContent -match [regex]::Escape($oldPath)) {
        $usedFiles[$normalizedPath] = $true
        continue
    }
    
    # Check for just the filename (less reliable, but might catch some)
    # Only if filename is unique enough (contains path segments)
    if ($relativePathOnly -match '/') {
        $pathSegments = $relativePathOnly -split '/'
        $lastTwoSegments = $pathSegments[-2] + '/' + $pathSegments[-1]
        if ($combinedContent -match [regex]::Escape($lastTwoSegments)) {
            $usedFiles[$normalizedPath] = $true
            continue
        }
    }
}
Write-Host ""

# Find unused files
foreach ($normalizedPath in $filePathMap.Keys) {
    if (-not $usedFiles.ContainsKey($normalizedPath)) {
        $unusedFiles[$normalizedPath] = $filePathMap[$normalizedPath]
    }
}

# Report results
Write-Host "Results:" -ForegroundColor Yellow
Write-Host "  Used: $($usedFiles.Count)" -ForegroundColor Green
Write-Host "  Unused: $($unusedFiles.Count)" -ForegroundColor $(if ($unusedFiles.Count -gt 0) { "Red" } else { "Green" })
Write-Host ""

# Build output content
$outputContent = @()
$outputContent += "Unused Media Files Report"
$outputContent += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$outputContent += ""
$outputContent += "Summary:"
$outputContent += "  Total media files: $($filePathMap.Count)"
$outputContent += "  Used: $($usedFiles.Count)"
$outputContent += "  Unused: $($unusedFiles.Count)"
if ($unusedFiles.Count -gt 0) {
    $unusedTotalSize = ($unusedFiles.Values | Measure-Object -Property Length -Sum).Sum
    $unusedTotalSizeFormatted = if ($unusedTotalSize -ge 1MB) {
        "$([math]::Round($unusedTotalSize / 1MB, 2)) MB"
    }
    elseif ($unusedTotalSize -ge 1KB) {
        "$([math]::Round($unusedTotalSize / 1KB, 2)) KB"
    }
    else {
        "$unusedTotalSize bytes"
    }
    $outputContent += "  Total unused size: $unusedTotalSizeFormatted"
}
$outputContent += ""

if ($unusedFiles.Count -gt 0) {
    $outputContent += "Unused media files:"
    $outputContent += ""
    
    $totalSize = 0
    foreach ($path in ($unusedFiles.Keys | Sort-Object)) {
        $file = $unusedFiles[$path]
        $constantName = $pathToConstant[$path]
        $fileSize = $file.Length
        $totalSize += $fileSize
        
        # Format file size
        $sizeFormatted = if ($fileSize -ge 1MB) {
            "$([math]::Round($fileSize / 1MB, 2)) MB"
        }
        elseif ($fileSize -ge 1KB) {
            "$([math]::Round($fileSize / 1KB, 2)) KB"
        }
        else {
            "$fileSize bytes"
        }
        
        $outputContent += "  $path"
        if ($constantName) {
            $outputContent += "    Constant: $constantName"
        }
        $outputContent += "    File: $($file.FullName)"
        $outputContent += "    Size: $sizeFormatted"
        $outputContent += ""
    }
    
    # Format total size
    $totalSizeFormatted = if ($totalSize -ge 1MB) {
        "$([math]::Round($totalSize / 1MB, 2)) MB"
    }
    elseif ($totalSize -ge 1KB) {
        "$([math]::Round($totalSize / 1KB, 2)) KB"
    }
    else {
        "$totalSize bytes"
    }
    
    $outputContent += "Total unused files: $($unusedFiles.Count)"
    $outputContent += "Total unused size: $totalSizeFormatted"
}
else {
    $outputContent += "All media files are in use!"
}

# Write to file
$outputContent | Out-File -FilePath $OutputFile -Encoding UTF8
Write-Host "Results written to: $OutputFile" -ForegroundColor Green

# Also show summary on console
if ($unusedFiles.Count -gt 0) {
    Write-Host "Found $($unusedFiles.Count) unused media files (see $OutputFile for details)" -ForegroundColor Red
}
else {
    Write-Host "All media files are in use!" -ForegroundColor Green
}

