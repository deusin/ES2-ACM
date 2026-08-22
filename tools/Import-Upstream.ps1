#requires -Version 5.1
<#
.SYNOPSIS
  Import the current Steam Workshop drop of an upstream mod onto its vendor branch.

.DESCRIPTION
  ACM is a fork-and-merge modpack. Each upstream mod has a branch `upstream/<mod>` that
  only ever receives pristine workshop drops. This script:
    1. checks out `upstream/<mod>` in a temporary worktree outside OneDrive,
    2. deletes the files recorded by the previous import (tools/upstream-manifests/<mod>.txt),
    3. copies the workshop folder in (renaming the mod's index XML where needed),
    4. writes the new manifest and commits.
  Afterwards run `git merge upstream/<mod>` on master; git's 3-way merge applies the clean
  files and surfaces only the definitions both ACM and upstream changed.

.EXAMPLE
  .\tools\Import-Upstream.ps1 -Mod esg
  git merge upstream/esg
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('esg', 'usc', 'moretraits', 'poltrees', 'elp')]
    [string]$Mod,

    # Stage and show the diff in the worktree but do not commit or remove the worktree.
    [switch]$NoCommit
)

$ErrorActionPreference = 'Stop'

$RepoRoot     = Split-Path $PSScriptRoot -Parent
$WorkshopRoot = 'D:\SteamLibrary\steamapps\workshop\content\392110'
$AcfPath      = 'D:\SteamLibrary\steamapps\workshop\appworkshop_392110.acf'
$WorktreeRoot = 'C:\Users\Kenny\source\worktrees'

# Index     = the mod's RuntimeModule XML in the workshop folder.
# IndexAs   = where to put it in ACM ($null = don't import; a second RuntimeModule XML in the
#             mod folder would make ES2 see a second mod).
# KeepIcon  = whether to import ModIcon.png (only ESG, whose icon ACM's baseline carries).
# Extra     = additional renames for non-game files worth keeping as reference.
# Rename    = optional scriptblock (relative path -> relative path) applied to every other file
#             (index and Extra renames take precedence). Used to park a mod under Addons\<name>\.
$Mods = @{
    esg        = @{ Id = '2828917317'; Index = 'ESCM.xml';                  IndexAs = 'ACM.xml'; KeepIcon = $true;  Extra = @{} }
    usc        = @{ Id = '3384708155'; Index = 'UsefulSkillColoursESG.xml'; IndexAs = $null;     KeepIcon = $false; Extra = @{ 'CHANGES.txt' = 'Documentation\UsefulSkillColours-CHANGES.txt' } }
    moretraits = @{ Id = '932777803';  Index = 'MoreTraits.xml';            IndexAs = $null;     KeepIcon = $false; Extra = @{} }
    poltrees   = @{ Id = '2856109167'; Index = 'PolTrees.xml';              IndexAs = $null;     KeepIcon = $false; Extra = @{} }
    # Endless Legend Populations is carried as a separate, toggleable module (see Addons/ in the
    # README): the whole drop lands under Addons\ACM-ELP\ with its index renamed, and master then
    # patches it (drops its ClassColonizedStarSystem override, its copies of vanilla traits, etc.).
    elp        = @{ Id = '1816492263'; Index = 'Minor.xml';                 IndexAs = 'Addons\ACM-ELP\ACM-ELP.xml'; KeepIcon = $true; Extra = @{}
                    Rename = { param($rel) return "Addons\ACM-ELP\$rel" } }
}
$AlwaysSkip = @('PublishedFile.Id', '.DS_Store', 'Thumbs.db')
# NOTE: mod file names contain [brackets]; every path cmdlet below must use -LiteralPath.

$m      = $Mods[$Mod]
$src    = Join-Path $WorkshopRoot $m.Id
$branch = "upstream/$Mod"
$wt     = Join-Path $WorktreeRoot "upstream-$Mod"
$manifestRel = "tools\upstream-manifests\$Mod.txt"

if (-not (Test-Path $src)) { throw "Workshop folder not found: $src (is the mod subscribed and downloaded?)" }

# --- workshop timestamp ---------------------------------------------------------------------
$ts = $null
if (Test-Path $AcfPath) {
    $acf = Get-Content $AcfPath -Raw
    $rx = [regex]::new('"' + $m.Id + '"\s*\{[^}]*?"timeupdated"\s*"(\d+)"')
    $match = $rx.Match($acf)
    if ($match.Success) { $ts = [long]$match.Groups[1].Value }
}
$dropDate = if ($ts) { [DateTimeOffset]::FromUnixTimeSeconds($ts).LocalDateTime.ToString('yyyy-MM-dd') } else { 'unknown-date' }
Write-Host "Importing $Mod (workshop $($m.Id), updated $dropDate) from $src"

# --- worktree -------------------------------------------------------------------------------
git -C $RepoRoot rev-parse --verify --quiet $branch | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Branch $branch does not exist. Create it from the commit where $Mod was last imported pristine, e.g. git branch $branch <sha>"
}
git -C $RepoRoot worktree prune
if (Test-Path -LiteralPath $wt) { Remove-Item -LiteralPath $wt -Recurse -Force }
New-Item -ItemType Directory -Force $WorktreeRoot | Out-Null
git -C $RepoRoot worktree add --quiet $wt $branch
if ($LASTEXITCODE -ne 0) { throw "git worktree add failed" }

try {
    # --- remove previous import --------------------------------------------------------------
    $prevManifest = Join-Path $wt $manifestRel
    if (Test-Path -LiteralPath $prevManifest) {
        $removed = 0
        foreach ($rel in (Get-Content $prevManifest | Where-Object { $_ -and -not $_.StartsWith('#') })) {
            $p = Join-Path $wt $rel
            if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Force; $removed++ }
        }
        Write-Host "Removed $removed files from previous import"
    }
    else {
        Write-Warning "No previous manifest at $manifestRel - files removed upstream will NOT be deleted this time."
    }

    # --- copy new drop -----------------------------------------------------------------------
    $manifest = New-Object System.Collections.Generic.List[string]
    $copied = 0
    foreach ($f in (Get-ChildItem $src -Recurse -File)) {
        $rel = $f.FullName.Substring($src.Length + 1)
        if ($AlwaysSkip -contains $f.Name) { continue }
        if ($rel -eq $m.Index) {
            if (-not $m.IndexAs) { continue }
            $rel = $m.IndexAs
        }
        elseif ($rel -eq 'ModIcon.png' -and -not $m.KeepIcon) { continue }
        elseif ($m.Extra.ContainsKey($rel)) { $rel = $m.Extra[$rel] }
        elseif ($m.Rename) { $rel = & $m.Rename $rel }

        $dest = Join-Path $wt $rel
        New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
        Copy-Item -LiteralPath $f.FullName -Destination $dest -Force
        $manifest.Add($rel)
        $copied++
    }
    Write-Host "Copied $copied files"

    New-Item -ItemType Directory -Force (Split-Path $prevManifest -Parent) | Out-Null
    $header = @("# Files imported from workshop item $($m.Id) ($Mod) on $dropDate. Maintained by tools/Import-Upstream.ps1.")
    ($header + ($manifest | Sort-Object)) | Set-Content -Path $prevManifest -Encoding UTF8

    # --- commit ------------------------------------------------------------------------------
    git -C $wt add -A
    $stat = git -C $wt diff --cached --stat | Select-Object -Last 1
    if (-not $stat) {
        Write-Host "No changes: $branch already matches the workshop drop."
        return
    }
    Write-Host $stat
    if ($NoCommit) {
        Write-Host "-NoCommit: changes are staged in $wt. Commit there, then 'git worktree remove' it."
        return
    }
    $msg = "Import $Mod workshop drop $dropDate" + $(if ($ts) { " (timeupdated $ts)" } else { '' })
    git -C $wt commit --quiet -m $msg
    if ($LASTEXITCODE -ne 0) { throw "git commit failed" }
    Write-Host "Committed on ${branch}: $(git -C $wt log --oneline -1)"
    Write-Host ""
    Write-Host "Next: git merge $branch"
}
finally {
    if (-not $NoCommit) {
        git -C $RepoRoot worktree remove --force $wt 2>$null
        git -C $RepoRoot worktree prune
    }
}
