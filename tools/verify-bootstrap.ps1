[CmdletBinding()]
param(
    [string]$SourceCommit = "6faec1c"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $repoRoot

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Get-GitOutput {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)
    $result = & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed"
    }
    return $result
}

$allFiles = @(Get-ChildItem -LiteralPath $repoRoot -Recurse -File -Force |
    Where-Object { $_.FullName -notlike "$repoRoot\.git\*" })
$relativePaths = @($allFiles | ForEach-Object {
    $_.FullName.Substring($repoRoot.Length + 1).Replace('\', '/')
})

$forbidden = @($relativePaths | Where-Object {
    $_ -like '.vscode/*' -or
    [IO.Path]::GetFileName($_) -ieq 'changelog.txt' -or
    $_ -match 'Bejeweled_(Cata|TBC|Vanilla)\.(lua|toc)$'
})
Assert-True ($forbidden.Count -eq 0) "Forbidden legacy/flavor files found: $($forbidden -join ', ')"

$runtimeTocs = @($relativePaths | Where-Object { $_ -like 'Bejeweled/*.toc' })
Assert-True ($runtimeTocs.Count -eq 0) "Runtime TOC found during analysis phase: $($runtimeTocs -join ', ')"

$legacyMappings = @{
    'Legacy/Bejeweled_Mainline.lua' = 'Bejeweled/Bejeweled_Mainline.lua'
    'Legacy/Bejeweled_Mainline.toc' = 'Bejeweled/Bejeweled_Mainline.toc'
}
foreach ($destination in $legacyMappings.Keys) {
    $source = $legacyMappings[$destination]
    $expected = (Get-GitOutput rev-parse "$SourceCommit`:$source").Trim()
    $indexEntry = (Get-GitOutput ls-files --stage -- $destination).Trim()
    Assert-True ($indexEntry -match '^\d+\s+([0-9a-f]{40})\s+\d+\s+') "Legacy file is not staged: $destination"
    $actual = $Matches[1]
    Assert-True ($actual -eq $expected) "Legacy hash mismatch: $destination"
}

$assetPaths = @(Get-GitOutput ls-tree -r --name-only $SourceCommit -- Bejeweled/images Bejeweled/sounds)
Assert-True ($assetPaths.Count -gt 0) "No source assets found"
foreach ($path in $assetPaths) {
    Assert-True (Test-Path -LiteralPath $path -PathType Leaf) "Missing preserved asset: $path"
    $expected = (Get-GitOutput rev-parse "$SourceCommit`:$path").Trim()
    $actual = (Get-GitOutput hash-object --no-filters $path).Trim()
    Assert-True ($actual -eq $expected) "Asset hash mismatch: $path"
}

$binaryExtensions = @('.tga', '.blp', '.mp3', '.ttf')
$strictUtf8 = [Text.UTF8Encoding]::new($false, $true)
foreach ($file in $allFiles) {
    if ($binaryExtensions -contains $file.Extension.ToLowerInvariant()) {
        continue
    }
    $bytes = [IO.File]::ReadAllBytes($file.FullName)
    $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
    Assert-True (-not $hasBom) "UTF-8 BOM found: $($file.FullName)"
    try {
        $null = $strictUtf8.GetString($bytes)
    }
    catch {
        throw "Invalid strict UTF-8: $($file.FullName)"
    }
}

$schedule = Get-Content -LiteralPath 'docs/analysis/batch-schedule.md'
$intervals = @()
foreach ($line in $schedule) {
    if ($line -match '^\|\s*\d+\s*\|\s*(\d{4})–(\d{4})\s*\|') {
        $intervals += ,@([int]$Matches[1], [int]$Matches[2])
    }
}
Assert-True ($intervals.Count -eq 17) "Expected 17 schedule intervals; found $($intervals.Count)"
$next = 1
foreach ($interval in $intervals) {
    Assert-True ($interval[0] -eq $next) "Schedule gap/overlap before $($interval[0])"
    Assert-True ($interval[1] -ge $interval[0]) "Invalid interval $($interval -join '-')"
    $next = $interval[1] + 1
}
Assert-True ($next -eq 8402) "Schedule does not end at 8401"

$report = Get-Content -LiteralPath 'docs/analysis/lines-0001-0500.md'
$covered = [Collections.Generic.HashSet[int]]::new()
$inCoverageTable = $false
foreach ($line in $report) {
    if ($line -eq '| Lines | Evidence represented |') {
        $inCoverageTable = $true
        continue
    }
    if ($inCoverageTable -and $line -like '## *') {
        $inCoverageTable = $false
    }
    if ($inCoverageTable -and $line -match '^\|\s*(\d+)(?:–(\d+))?\s*\|') {
        $start = [int]$Matches[1]
        $end = if ($Matches[2]) { [int]$Matches[2] } else { $start }
        if ($start -le 500 -and $end -le 500) {
            for ($number = $start; $number -le $end; $number++) {
                Assert-True ($covered.Add($number)) "Duplicate batch-01 coverage for line $number"
            }
        }
    }
}
Assert-True ($covered.Count -eq 500) "Batch-01 coverage contains $($covered.Count) of 500 lines"

$lineCount = (Get-Content -LiteralPath 'Legacy/Bejeweled_Mainline.lua').Count
Assert-True ($lineCount -eq 8401) "Legacy source has $lineCount lines, expected 8401"

Write-Output "Verified: forbidden files absent; legacy and $($assetPaths.Count) asset hashes match $SourceCommit."
Write-Output "Verified: strict UTF-8 text, exact 8,401-line schedule, and complete batch-01 line coverage."
