# Script to replace hardcoded media paths with LUIE_MEDIA constants

param(
    [string]$MediaPathsFile = "LuiMedia\MediaPaths.lua",
    [string[]]$FilesToProcess = @(),
    [string]$Folder = "",
    [switch]$DryRun = $false
)

# Read MediaPaths.lua and build a mapping from paths to constants
Write-Host "Reading media paths from: $MediaPathsFile" -ForegroundColor Cyan

if (-not (Test-Path $MediaPathsFile)) {
    Write-Host "Error: MediaPaths.lua not found: $MediaPathsFile" -ForegroundColor Red
    exit 1
}

$pathToConstant = @{}
$content = Get-Content $MediaPathsFile -Raw

# Parse constants from MediaPaths.lua
# Pattern: LUIE_MEDIA_... = "LuiMedia/media/..."
$pattern = 'LUIE_MEDIA_\w+\s*=\s*"([^"]+)"'
$regexMatches = [regex]::Matches($content, $pattern)

foreach ($match in $regexMatches) {
    $constantName = $match.Groups[0].Value -replace '\s*=\s*"[^"]+"', ''
    $path = $match.Groups[1].Value
    
    # Normalize path - handle both forward and backslashes
    $normalizedPath = $path -replace '\\', '/'
    
    # Store both the new path (LuiMedia/media/...) and old path (LuiExtended/media/...)
    $pathToConstant[$normalizedPath] = $constantName
    
    # Also map old LuiExtended paths to the same constant
    $oldPath = $normalizedPath -replace '^LuiMedia/', 'LuiExtended/'
    if ($oldPath -ne $normalizedPath) {
        $pathToConstant[$oldPath] = $constantName
    }
}

Write-Host "Loaded $($pathToConstant.Count) path mappings" -ForegroundColor Cyan

# Function to normalize path for comparison (treats hyphens and underscores as equivalent)
function Convert-PathForComparison {
    param([string]$path)
    # Normalize slashes and create a comparison key that treats hyphens/underscores as equivalent
    $normalized = $path -replace '\\', '/'
    # Create a key that normalizes hyphens and underscores for comparison
    $key = $normalized -replace '-', '_'
    return @{
        Original = $normalized
        Key      = $key
    }
}

# Build a lookup map using normalized keys
$normalizedPathToConstant = @{}
foreach ($entry in $pathToConstant.GetEnumerator()) {
    $normalized = Convert-PathForComparison $entry.Key
    $normalizedPathToConstant[$normalized.Key] = @{
        Constant     = $entry.Value
        OriginalPath = $normalized.Original
    }
}

# Function to find and replace media paths in a file
function Update-FileMediaPaths {
    param([string]$filePath)
    
    if (-not (Test-Path $filePath)) {
        Write-Host "Warning: File not found: $filePath" -ForegroundColor Yellow
        return 0
    }
    
    $fileContent = Get-Content $filePath -Raw
    $replacements = 0
    
    # Find all quoted strings containing media paths
    # Pattern matches: "LuiExtended/media/..." or "LuiMedia/media/..."
    $mediaPathPattern = '"(Lui(Extended|Media)/media/[^"]+)"'
    $pathMatches = [regex]::Matches($fileContent, $mediaPathPattern)
    
    # Process matches in reverse order to preserve positions
    $matchesToReplace = @()
    $unmatchedPaths = @()
    foreach ($match in $pathMatches) {
        $fullMatch = $match.Groups[0].Value  # Full match including quotes
        $path = $match.Groups[1].Value       # Path without quotes
        
        # Normalize path for comparison
        $normalized = Convert-PathForComparison $path
        
        # Try exact match first
        if ($pathToConstant.ContainsKey($normalized.Original)) {
            $constantName = $pathToConstant[$normalized.Original]
            $matchesToReplace += @{
                FullMatch = $fullMatch
                Constant  = $constantName
                Path      = $normalized.Original
            }
        }
        # Try normalized key match (handles hyphen/underscore differences)
        elseif ($normalizedPathToConstant.ContainsKey($normalized.Key)) {
            $constantName = $normalizedPathToConstant[$normalized.Key].Constant
            $matchesToReplace += @{
                FullMatch = $fullMatch
                Constant  = $constantName
                Path      = $normalized.Original
            }
        }
        else {
            # No match found - this path doesn't have a constant
            $unmatchedPaths += $normalized.Original
        }
    }
    
    # Report unmatched paths
    if ($unmatchedPaths.Count -gt 0) {
        Write-Host "  Warning: Found $($unmatchedPaths.Count) path(s) without matching constants:" -ForegroundColor Yellow
        foreach ($unmatched in $unmatchedPaths) {
            Write-Host "    $unmatched" -ForegroundColor Yellow
        }
    }
    
    # Replace matches (in reverse order to preserve positions)
    for ($i = $matchesToReplace.Count - 1; $i -ge 0; $i--) {
        $item = $matchesToReplace[$i]
        $oldValue = $item.FullMatch
        $newValue = $item.Constant
        
        if ($fileContent -match [regex]::Escape($oldValue)) {
            $fileContent = $fileContent -replace [regex]::Escape($oldValue), $newValue
            $replacements++
            
            if ($DryRun) {
                Write-Host "  Would replace: $($item.Path) -> $newValue" -ForegroundColor Yellow
            }
            else {
                Write-Host "  Replaced: $($item.Path) -> $newValue" -ForegroundColor Green
            }
        }
    }
    
    if ($replacements -gt 0) {
        if (-not $DryRun) {
            # Preserve original line endings
            $encoding = [System.Text.Encoding]::UTF8
            [System.IO.File]::WriteAllText((Resolve-Path $filePath).Path, $fileContent, $encoding)
        }
        return $replacements
    }
    
    return 0
}

# Collect files to process
$filesToProcessList = @()

# If folder is specified, recursively find all .lua files
if ($Folder -ne "") {
    if (-not (Test-Path $Folder)) {
        Write-Host "Error: Folder not found: $Folder" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "`nScanning folder recursively: $Folder" -ForegroundColor Cyan
    $luaFiles = Get-ChildItem -Path $Folder -Filter "*.lua" -Recurse -File
    $filesToProcessList = $luaFiles | ForEach-Object { $_.FullName }
    Write-Host "Found $($filesToProcessList.Count) Lua file(s)" -ForegroundColor Cyan
}

# Add explicitly specified files
if ($FilesToProcess.Count -gt 0) {
    $filesToProcessList += $FilesToProcess
}

# Process files
if ($filesToProcessList.Count -eq 0) {
    Write-Host "No files specified. Use -Folder or -FilesToProcess parameter." -ForegroundColor Yellow
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\replace_media_paths.ps1 -Folder 'LuiData'" -ForegroundColor Yellow
    Write-Host "  .\replace_media_paths.ps1 -FilesToProcess @('LuiData\Effects\KeepUpgradeAlliance.lua')" -ForegroundColor Yellow
    exit 0
}

$totalReplacements = 0
$filesProcessed = 0
$filesWithChanges = 0

foreach ($file in $filesToProcessList) {
    $relativePath = $file -replace [regex]::Escape((Get-Location).Path + "\"), ""
    Write-Host "`nProcessing: $relativePath" -ForegroundColor Cyan
    $replacements = Update-FileMediaPaths -filePath $file
    $filesProcessed++
    if ($replacements -gt 0) {
        $filesWithChanges++
        $totalReplacements += $replacements
    }
}

Write-Host "`n" -NoNewline
Write-Host "Done! " -ForegroundColor Green -NoNewline
Write-Host "Processed $filesProcessed file(s), " -NoNewline
Write-Host "$filesWithChanges with changes, " -ForegroundColor Cyan -NoNewline
Write-Host "$totalReplacements total replacement(s)." -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "(Dry run - no files were modified)" -ForegroundColor Yellow
}

