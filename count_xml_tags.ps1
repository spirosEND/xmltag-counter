# count_xml_tags.ps1
# Script to count occurrences of a specific XML tag in all XML files within a directory

param(
    [Parameter(Mandatory=$true)]
    [string]$Directory,
    
    [Parameter(Mandatory=$true)]
    [string]$TagName,
    
    [string[]]$FileExtensions = @("*.xml", "*.out"),
    
    [switch]$ShowDebug,
    
    [switch]$ShowProgress
)

# Validate directory exists
if (-not (Test-Path -Path $Directory -PathType Container)) {
    Write-Host "Error: '$Directory' is not a valid directory." -ForegroundColor Red
    exit 1
}

$resolvedPath = (Resolve-Path $Directory).Path
Write-Host "`nSearching for tag: <$TagName>" -ForegroundColor Cyan
Write-Host "In directory: $resolvedPath" -ForegroundColor Cyan
Write-Host "File extensions: $($FileExtensions -join ', ')" -ForegroundColor Cyan

Write-Host "`nScanning files..." -ForegroundColor Yellow

$totalCount = 0
$fileCounts = @{}
$processedFiles = 0
$skippedFiles = 0

# Get all files matching the extensions recursively
$xmlFiles = @()

foreach ($ext in $FileExtensions) {
    $foundFiles = Get-ChildItem -Path $Directory -Filter $ext -Recurse -File -ErrorAction SilentlyContinue
    $xmlFiles += $foundFiles
}

# Remove duplicates (in case of overlap)
$xmlFiles = $xmlFiles | Sort-Object FullName -Unique

$totalFiles = $xmlFiles.Count
Write-Host "Found $totalFiles file(s) matching extensions: $($FileExtensions -join ', ')" -ForegroundColor White
Write-Host "Processing files..." -ForegroundColor Yellow

# Try to inspect first file for debugging
if ($ShowDebug -and $xmlFiles.Count -gt 0) {
    $firstFile = $xmlFiles[0]
    Write-Host "`n[DEBUG] Inspecting first file: $($firstFile.FullName)" -ForegroundColor Magenta
    try {
        [xml]$sampleXml = Get-Content $firstFile.FullName -ErrorAction Stop
        
        # Show namespace info
        Write-Host "[DEBUG] Root element: $($sampleXml.DocumentElement.Name)" -ForegroundColor Magenta
        Write-Host "[DEBUG] Root namespace: $($sampleXml.DocumentElement.NamespaceURI)" -ForegroundColor Magenta
        
        # Try with namespace wildcard
        Write-Host "[DEBUG] Trying XPath: //*[local-name()='$TagName']" -ForegroundColor Magenta
        $nodes2 = $sampleXml.SelectNodes("//*[local-name()='$TagName']")
        Write-Host "[DEBUG] Found $($nodes2.Count) nodes with local-name()" -ForegroundColor Magenta
        
        # Show some actual tag names found
        Write-Host "[DEBUG] Sample tags found in first file (first 15):" -ForegroundColor Magenta
        $allNodes = $sampleXml.SelectNodes("//*")
        $allNodes | Select-Object -First 15 | ForEach-Object {
            $ns = if ($_.NamespaceURI) { $_.NamespaceURI } else { "(no namespace)" }
            Write-Host "  Tag: $($_.LocalName) | Full: $($_.Name) | NS: $ns" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "[DEBUG] Error inspecting first file: $_" -ForegroundColor Red
    }
    Write-Host ""
}

$startTime = Get-Date

foreach ($file in $xmlFiles) {
    try {
        # Load XML file
        [xml]$xmlContent = Get-Content $file.FullName -ErrorAction Stop
        
        # Count using namespace-agnostic approach (handles default namespaces)
        $allNodes = $xmlContent.SelectNodes("//*")
        $count = ($allNodes | Where-Object { $_.LocalName -eq $TagName }).Count
        
        if ($count -gt 0) {
            $fileCounts[$file.FullName] = $count
            $totalCount += $count
        }
        
        $processedFiles++
        
        # Show progress every 10 files or if ShowProgress is enabled
        if ($ShowProgress -or ($processedFiles % 10 -eq 0)) {
            $percent = [math]::Round(($processedFiles / $totalFiles) * 100, 1)
            $elapsed = (Get-Date) - $startTime
            $avgTime = $elapsed.TotalSeconds / [math]::Max($processedFiles,1)
            $remaining = ($totalFiles - $processedFiles) * $avgTime
            $remainingTime = [TimeSpan]::FromSeconds($remaining)
            
            Write-Host "  Progress: $processedFiles/$totalFiles ($percent%) | Found so far: $totalCount | Est. remaining: $($remainingTime.ToString('mm\:ss'))" -ForegroundColor Gray
        }
        
        if ($ShowDebug -and $processedFiles -le 3) {
            Write-Host "  Processed: $($file.Name) - Found: $count" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  Warning: Skipping invalid XML file: $($file.Name) - $_" -ForegroundColor Yellow
        $skippedFiles++
        
        if ($ShowProgress) {
            $percent = [math]::Round(($processedFiles / $totalFiles) * 100, 1)
            Write-Host "  Progress: $processedFiles/$totalFiles ($percent%)" -ForegroundColor Gray
        }
    }
}

$endTime = Get-Date
$totalTime = $endTime - $startTime

# Display results
Write-Host "`n" + ("="*70) -ForegroundColor Gray
Write-Host "RESULTS" -ForegroundColor Green
Write-Host ("="*70) -ForegroundColor Gray
Write-Host "Tag name: <$TagName>" -ForegroundColor Cyan
Write-Host "Total occurrences: $totalCount" -ForegroundColor Green
Write-Host "Files processed: $processedFiles" -ForegroundColor White
Write-Host "Processing time: $($totalTime.ToString('mm\:ss'))" -ForegroundColor White
if ($skippedFiles -gt 0) {
    Write-Host "Files skipped (invalid XML): $skippedFiles" -ForegroundColor Yellow
}

if ($fileCounts.Count -gt 0) {
    Write-Host "`nFiles containing the tag: $($fileCounts.Count)" -ForegroundColor Cyan
    Write-Host ("-"*70) -ForegroundColor Gray
    
    if ($fileCounts.Count -le 20) {
        # Show all files if 20 or fewer
        $fileCounts.GetEnumerator() | Sort-Object Name | ForEach-Object {
            Write-Host "$($_.Name): $($_.Value)" -ForegroundColor White
        }
    }
    else {
        # Show summary if many files
        Write-Host "Showing first 10 files:" -ForegroundColor Yellow
        $fileCounts.GetEnumerator() | Sort-Object Name | Select-Object -First 10 | ForEach-Object {
            Write-Host "$($_.Name): $($_.Value)" -ForegroundColor White
        }
        Write-Host "... and $($fileCounts.Count - 10) more files" -ForegroundColor Gray
    }
}
else {
    Write-Host "`nNo occurrences found in any XML file." -ForegroundColor Yellow
    Write-Host "`nTroubleshooting tips:" -ForegroundColor Yellow
    Write-Host "1. Check if the tag name is case-sensitive (e.g., RecordID vs RecordId)" -ForegroundColor White
    Write-Host "2. Run with -ShowDebug flag to see what tags are actually in your XML files" -ForegroundColor White
    Write-Host "3. The tag might be in a namespace - the script handles this automatically" -ForegroundColor White
}

Write-Host ("`n" + ("="*70)) -ForegroundColor Gray