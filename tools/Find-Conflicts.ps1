#requires -Version 5.1
<#
.SYNOPSIS
  Report definitions that both ACM and another mod define (same element type + Name).

.DESCRIPTION
  ES2 resolves duplicate definitions by load order: the last-loaded mod's definition wins
  wholesale. So any overlap listed here means one mod silently shadows the other when both
  are enabled. Use this to decide whether a workshop mod can run alongside ACM as-is, or
  whether its content has to be merged into ACM.

  Every *.xml under each root is parsed and the direct children of the root <Datatable>
  are taken as definitions, keyed "<ElementName>:<Name attribute>". Localization keys
  (LocalizationPair) are reported separately since overlapping text is usually harmless.

.PARAMETER Mod
  Workshop item id (folder under the workshop root) or a full path to a mod folder.

.EXAMPLE
  .\tools\Find-Conflicts.ps1 -Mod 3257341334     # Endless Anomalies
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Mod,
    [string]$AcmRoot = (Split-Path $PSScriptRoot -Parent),
    [string]$WorkshopRoot = 'D:\SteamLibrary\steamapps\workshop\content\392110',
    [switch]$ShowLocalization
)

$ErrorActionPreference = 'Stop'
$modRoot = if (Test-Path $Mod) { (Resolve-Path $Mod).Path } else { Join-Path $WorkshopRoot $Mod }
if (-not (Test-Path $modRoot)) { throw "Mod folder not found: $modRoot" }

function Get-Definitions([string]$root) {
    $defs = @{}
    foreach ($f in (Get-ChildItem $root -Recurse -File -Filter *.xml)) {
        $rel = $f.FullName.Substring($root.Length + 1)
        $doc = New-Object System.Xml.XmlDocument
        try { $doc.Load($f.FullName) } catch { Write-Warning "Skipping unparseable $rel : $($_.Exception.Message)"; continue }
        $rootEl = $doc.DocumentElement
        if (-not $rootEl) { continue }
        foreach ($child in $rootEl.ChildNodes) {
            if ($child.NodeType -ne 'Element') { continue }
            $name = $child.GetAttribute('Name')
            if (-not $name) { continue }
            $key = "$($child.LocalName):$name"
            if (-not $defs.ContainsKey($key)) { $defs[$key] = New-Object System.Collections.Generic.List[string] }
            $defs[$key].Add($rel)
        }
    }
    return $defs
}

Write-Host "Scanning ACM: $AcmRoot"
$acm = Get-Definitions $AcmRoot
Write-Host "Scanning mod: $modRoot"
$other = Get-Definitions $modRoot
Write-Host ("ACM definitions: {0}   mod definitions: {1}" -f $acm.Count, $other.Count)

$overlap = $other.Keys | Where-Object { $acm.ContainsKey($_) } | Sort-Object
$loc     = $overlap | Where-Object { $_ -like 'LocalizationPair:*' }
$real    = $overlap | Where-Object { $_ -notlike 'LocalizationPair:*' -and $_ -notlike 'RuntimeModule:*' }

Write-Host ""
if (-not $real) {
    Write-Host "No definition overlaps. This mod should layer cleanly on ACM (load order irrelevant)." -ForegroundColor Green
}
else {
    Write-Host ("{0} overlapping definitions (the later-loaded mod wins each one wholesale):" -f $real.Count) -ForegroundColor Yellow
    $real | Group-Object { $_.Split(':')[0] } | Sort-Object Name | ForEach-Object {
        Write-Host ""
        Write-Host ("  {0} ({1})" -f $_.Name, $_.Count) -ForegroundColor Cyan
        foreach ($k in $_.Group) {
            $n = $k.Substring($k.IndexOf(':') + 1)
            Write-Host ("    {0,-60} ACM: {1}  |  mod: {2}" -f $n, ($acm[$k] -join ', '), ($other[$k] -join ', '))
        }
    }
}

Write-Host ""
Write-Host ("Localization key overlaps: {0}{1}" -f $loc.Count, $(if ($loc.Count -and -not $ShowLocalization) { '  (use -ShowLocalization to list)' } else { '' }))
if ($ShowLocalization) { $loc | ForEach-Object { "    " + $_.Substring($_.IndexOf(':') + 1) } }
