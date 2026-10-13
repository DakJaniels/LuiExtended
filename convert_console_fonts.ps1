# Convert baseline OpenType fonts to the console Slug subset.
# Run from the LuiExtended directory:
#   powershell -File .\convert_console_fonts.ps1

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspaceRoot = Split-Path -Parent $scriptDirectory
$slugfontExecutable = Join-Path $workspaceRoot "slugfont.exe"
$sourceRoot = Join-Path $workspaceRoot "non_slug_fonts"
$outputRoot = Join-Path $scriptDirectory "LuiMedia\media\fonts\console"

if (-not (Test-Path $slugfontExecutable)) {
    Write-Host "Error: slugfont.exe not found: $slugfontExecutable" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $sourceRoot)) {
    Write-Host "Error: source font folder not found: $sourceRoot" -ForegroundColor Red
    exit 1
}

# Locale coverage for en/de/fr/ru. slugfont also keeps Basic Latin and Latin-1
# whenever any -range switch is present. Glyphs the source font does not have are skipped.
$rangeArguments = @(
    "-range(0x100,0x17F)",
    "-range(0x300,0x36F)",
    "-range(0x400,0x4FF)",
    "-range(0x2000,0x206F)"
)

$sourceFonts = Get-ChildItem -Path $sourceRoot -Recurse -File | Where-Object { $_.Extension -in @(".ttf", ".otf") } | Sort-Object FullName
if ($sourceFonts.Count -eq 0) {
    Write-Host "Error: no .ttf or .otf files found in $sourceRoot" -ForegroundColor Red
    exit 1
}

Set-Location $workspaceRoot

$totalBytes = 0
$convertedCount = 0

foreach ($sourceFont in $sourceFonts) {
    $relativeDirectory = $sourceFont.DirectoryName.Substring($sourceRoot.Length).TrimStart("\", "/")
    $outputDirectory = Join-Path $outputRoot $relativeDirectory
    if (-not (Test-Path $outputDirectory)) {
        New-Item -ItemType Directory -Path $outputDirectory | Out-Null
    }

    $outputName = [System.IO.Path]::ChangeExtension($sourceFont.Name, ".slug")
    $outputFile = Join-Path $outputDirectory $outputName
    $arguments = @($sourceFont.FullName, "-o", $outputFile) + $rangeArguments

    & $slugfontExecutable @arguments
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: slugfont failed for $($sourceFont.FullName) (exit $LASTEXITCODE)" -ForegroundColor Red
        exit $LASTEXITCODE
    }

    $outputItem = Get-Item $outputFile
    $totalBytes += $outputItem.Length
    $convertedCount += 1
    $relativeOutput = $outputItem.FullName.Substring($outputRoot.Length).TrimStart("\", "/")
    "{0,12:N0}  {1}" -f $outputItem.Length, $relativeOutput
}

""
"COUNT {0}  TOTAL {1:N0} bytes ({2:N1} MB)" -f $convertedCount, $totalBytes, ($totalBytes / 1MB)
