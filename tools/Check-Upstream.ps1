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

.EXAMPLE
  .\tools\Check-Upstream.ps1
#>
[CmdletBinding()]
param()

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
