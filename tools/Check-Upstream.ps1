#requires -Version 5.1
<#
.SYNOPSIS
  Ask Steam whether any mod folded into ACM has been updated since it was last imported.

.DESCRIPTION
  Queries the public Steam Web API (ISteamRemoteStorage/GetPublishedFileDetails, no key needed) for each
  workshop item in the table below and compares its time_updated with the timeupdated recorded in the
  last "Import <mod> workshop drop ..." commit on the mod's vendor branch (upstream/<mod>). Nothing is
  downloaded. To refresh one that changed: subscribe/let Steam download it, then
  .\tools\Import-Upstream.ps1 -Mod <mod> and git merge upstream/<mod>.

.PARAMETER Notes
  Also fetch each mod's workshop change-log page and print the author's notes for updates newer than
  the imported drop (with -All, print every note). Steam's change-log dates omit the year for the
  current year, so January entries right after a year change may be mis-dated by one year.

.EXAMPLE
  .\tools\Check-Upstream.ps1
  .\tools\Check-Upstream.ps1 -Notes
  .\tools\Check-Upstream.ps1 -Notes -All
#>
[CmdletBinding()]
param(
    [switch]$Notes,
    [switch]$All
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path $PSScriptRoot -Parent

# mod key (= vendor branch suffix) -> workshop id. Keep in sync with Import-Upstream.ps1 and the README.
$Mods = [ordered]@{
    esg        = '2828917317'
    usc        = '3384708155'
    moretraits = '932777803'
    poltrees   = '2856109167'
    elp        = '1816492263'
    mhr        = '3771413185'
    samus      = '3268328942'
    arkonportal = '1788325573'
    afhs       = '3175229111'
    em         = '1316786885'
    ea         = '3257341334'
    dsm        = '1263186686'
    worthydeeds = '1587659427'
    kaizen     = '1130687397'
}

$body = @{ itemcount = $Mods.Count }
$i = 0
foreach ($id in $Mods.Values) { $body["publishedfileids[$i]"] = $id; $i++ }
$resp = Invoke-RestMethod -Method Post -Uri 'https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/' -Body $body
$details = @{}
foreach ($d in $resp.response.publishedfiledetails) { $details[[string]$d.publishedfileid] = $d }

$epoch = [DateTimeOffset]::FromUnixTimeSeconds(0)
$rows = foreach ($mod in $Mods.Keys) {
    $id = $Mods[$mod]
    $d = $details[$id]
    $remote = if ($d -and $d.time_updated) { [DateTimeOffset]::FromUnixTimeSeconds([int64]$d.time_updated).LocalDateTime } else { $null }

    $subject = git -C $RepoRoot log -1 --format=%s "upstream/$mod" 2>$null
    $local = $null
    if ($subject -match 'timeupdated (\d+)') { $local = [DateTimeOffset]::FromUnixTimeSeconds([int64]$Matches[1]).LocalDateTime }

    $status = if (-not $remote) { 'no API data' }
              elseif (-not $local) { 'no vendor branch' }
              elseif ($remote -gt $local) { 'UPDATED upstream' }
              else { 'up to date' }
    [pscustomobject]@{
        Mod      = $mod
        Title    = if ($d) { $d.title } else { '?' }
        Imported = if ($local) { $local.ToString('yyyy-MM-dd') } else { '-' }
        Upstream = if ($remote) { $remote.ToString('yyyy-MM-dd') } else { '-' }
        Status   = $status
        Url      = "https://steamcommunity.com/sharedfiles/filedetails/?id=$id"
    }
}
$rows | Format-Table -AutoSize -Wrap

if (-not $Notes) { return }

foreach ($row in $rows) {
    $id = $Mods[$row.Mod]
    $since = if ($row.Imported -ne '-') { [datetime]::ParseExact($row.Imported, 'yyyy-MM-dd', $null) } else { [datetime]::MinValue }
    try {
        $html = (Invoke-WebRequest -UseBasicParsing -UserAgent 'Mozilla/5.0' -Uri "https://steamcommunity.com/sharedfiles/filedetails/changelog/$id").Content
    }
    catch { Write-Warning "$($row.Mod): could not fetch change log ($($_.Exception.Message))"; continue }

    $entries = [regex]::Matches($html, '<div class="changelog headline">(.*?)</div>\s*<p id="\d+">(.*?)</p>', 'Singleline')
    Write-Host ''
    Write-Host "=== $($row.Title) ($($row.Mod), imported $($row.Imported)) - $($entries.Count) change-log entries"
    $shown = 0
    foreach ($e in $entries) {
        $head = [regex]::Replace($e.Groups[1].Value, '<[^>]+>', '') -replace '\s+', ' '
        $head = $head.Trim()
        # "Update: May 31 @ 8:15am" (current year) or "Update: Dec 12, 2025 @ 3:36pm"
        $date = $null
        if ($head -match 'Update:\s+(\w+ \d+)(?:, (\d{4}))? @') {
            $y = if ($Matches[2]) { $Matches[2] } else { (Get-Date).Year }
            try { $date = [datetime]::ParseExact("$($Matches[1]) $y", 'MMM d yyyy', [cultureinfo]::InvariantCulture) } catch { }
        }
        if (-not $All -and $date -and $date.Date -le $since.Date) { continue }
        $text = [System.Net.WebUtility]::HtmlDecode(($e.Groups[2].Value -replace '<br\s*/?>', "`n" -replace '<[^>]+>', '')).Trim()
        Write-Host ''
        Write-Host "--- $head"
        Write-Host $text
        $shown++
    }
    if ($shown -eq 0) { Write-Host '(no notes newer than the imported drop)' }
}
