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
    [ValidateSet('esg', 'usc', 'moretraits', 'poltrees', 'elp', 'mhr', 'samus', 'arkonportal')]
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
# KeepIcon  = whether to import the mod's preview image (only ESG, whose icon ACM's baseline carries).
# Icon      = the preview image's name when it is not ModIcon.png.
# Extra     = additional renames for non-game files worth keeping as reference.
# Rename    = optional scriptblock (relative path -> relative path) applied to every other file
#             (index and Extra renames take precedence). Used when a mod's file names collide with
#             ACM's; the renamed paths must still match a FilePath pattern in ACM.xml (see elp).
$Mods = @{
    esg        = @{ Id = '2828917317'; Index = 'ESCM.xml';                  IndexAs = 'ACM.xml'; KeepIcon = $true;  Extra = @{} }
    usc        = @{ Id = '3384708155'; Index = 'UsefulSkillColoursESG.xml'; IndexAs = $null;     KeepIcon = $false; Extra = @{ 'CHANGES.txt' = 'Documentation\UsefulSkillColours-CHANGES.txt' } }
    # More Traits / Political Skill Trees: their english locale file shares ESG's path; master keeps them
    # as ES2_Localization_Locales[MoreTraits].xml / ES2_Localization_Locales_PoliticalTrees.xml.
    moretraits = @{ Id = '932777803';  Index = 'MoreTraits.xml';            IndexAs = $null;     KeepIcon = $false; Extra = @{}
                    Rename = { param($rel) if ($rel -match '^Localization\\(.+)\\ES2_Localization_Locales\.xml$') { return "Localization\$($Matches[1])\ES2_Localization_Locales[MoreTraits].xml" }; return $rel } }
    poltrees   = @{ Id = '2856109167'; Index = 'PolTrees.xml';              IndexAs = $null;     KeepIcon = $false; Extra = @{}
                    Rename = { param($rel) if ($rel -match '^Localization\\(.+)\\ES2_Localization_Locales\.xml$') { return "Localization\$($Matches[1])\ES2_Localization_Locales_PoliticalTrees.xml" }; return $rel } }
    # Endless Legend Populations is merged into ACM's own folders: every file is renamed with an
    # [ELP] suffix so it sits next to ESG's files without replacing any (ACM.xml's wildcards pick
    # them up). Master then patches the drop (deletes SimulationDescriptors[ELP_ColonizedStarSystem],
    # strips vanilla trait copies from FactionTraits[ELP_Minor], bug fixes) - see README.
    elp        = @{ Id = '1816492263'; Index = 'Minor.xml';                 IndexAs = $null;     KeepIcon = $false; Extra = @{}
                    Rename = {
                        param($rel)
                        switch -Regex ($rel) {
                            '^GalaxyGenerator\\WeightTableDefinitions\.xml$'             { return 'Galaxy\WeightTableDefinitions[ELP].xml' }
                            '^Gui\\GuiElements\[(.+)\]\.xml$'                            { return "GUI\GUIElements[ELP_$($Matches[1])].xml" }
                            '^Localization\\([^\\]+)\\(ES2_Localization_.+)\.xml$'      { return "Localization\$($Matches[1])\$($Matches[2])[ELP].xml" }
                            '^Mapping\\FleetNameMappingDefinitions\.xml$'                { return 'Mapping\FleetNameMappingDefinitions[ELP].xml' }
                            '^Simulation\\ConstructibleElement_Industry\.xml$'           { return 'Simulation\ConstructibleElement_Industry[ELP].xml' }
                            '^Simulation\\Factions\.xml$'                                { return 'Simulation\Factions[ELP].xml' }
                            '^Simulation\\FactionTraits\[(.+)\]\.xml$'                   { return "Simulation\FactionTraits[ELP_$($Matches[1])].xml" }
                            '^Simulation\\MinorFactionPersonalityDefinitions\.xml$'      { return 'Simulation\MinorFactionPersonalityDefinitions[ELP].xml' }
                            '^Simulation\\PopulationCollectionBonusTraits\.xml$'         { return 'Simulation\PopulationCollectionBonusTraits[ELP].xml' }
                            '^Simulation\\PopulationDefinitions\.xml$'                   { return 'Simulation\PopulationDefinitions[ELP].xml' }
                            '^Simulation\\PopulationModifiersTraits\.xml$'               { return 'Simulation\Traits\PopulationModifiersTraits[ELP].xml' }
                            '^Simulation\\PopulationModifiersTraits\[(.+)\]\.xml$'       { return "Simulation\Traits\PopulationModifiersTraits[ELP_$($Matches[1])].xml" }
                            '^Simulation\\SimulationDescriptors\[(.+)\]\.xml$'           { return "Simulation\SimulationDescriptors[ELP_$($Matches[1])].xml" }
                            default                                                      { return $rel }
                        }
                    } }
    # Minor Heroes Reimagined [ESG+PST] (mdel). New content gets an [MHR] suffix; the drop's partial
    # copies of ESG/USC files (HeroDefinitions*, ConstructibleElement_Industry[PlanetColonization],
    # GuiElements[Extended], GUIElements[HeroSkills], GalaxyGenerator/WeightTableDefinitions) land as
    # [MHR_*] files that master grafts into ACM's own copies and deletes - see README.
    # Samus Aran: one hero; every file gets a [Samus] suffix. Its FactionTraits.xml (Terran affinity
    # recruiting Samus) is deleted on master - ESG's affinity with the mercenary designs wins.
    samus      = @{ Id = '3268328942'; Index = 'Samus.xml';                 IndexAs = $null;     KeepIcon = $false; Extra = @{}
                    Rename = {
                        param($rel)
                        switch -Regex ($rel) {
                            '^Gui\\GuiElements\.xml$'                            { return 'GUI\GUIElements[Samus].xml' }
                            '^Localization\\([^\\]+)\\(ES2_Localization_.+)\.xml$' { return "Localization\$($Matches[1])\$($Matches[2])[Samus].xml" }
                            '^Simulation\\([^\\\[]+)\.xml$'                     { return "Simulation\$($Matches[1])[Samus].xml" }
                            default                                               { return $rel }
                        }
                    } }
    # Arkon Portal: every file gets an [Arkon] suffix on ACM's paths. Master drops the 500-point cheat trait
    # and gates the portal improvement/tech behind the EnableArkonPortal game setting.
    arkonportal = @{ Id = '1788325573'; Index = 'ArkonPortal.xml';          IndexAs = $null;     KeepIcon = $false; Icon = 'Icon.png'; Extra = @{}
                    Rename = {
                        param($rel)
                        switch -Regex ($rel) {
                            '^Gui\\GuiElements\[PORTAL\]\.xml$'                    { return 'GUI\GUIElements[Arkon].xml' }
                            '^Localization\\([^\\]+)\\(ES2_Localization_.+)\.xml$' { return "Localization\$($Matches[1])\$($Matches[2])[Arkon].xml" }
                            '^Simulation\\StarSYSImpro\[PORTAL\]\.xml$'            { return 'Simulation\ConstructibleElement_Industry[Arkon].xml' }
                            '^Simulation\\TechnologyDefinitions\[PORTAL\]\.xml$'   { return 'Simulation\ConstructibleElement_Science[Arkon].xml' }
                            '^Simulation\\(.+)\[PORTAL\]\.xml$'                   { return "Simulation\$($Matches[1])[Arkon].xml" }
                            default                                               { return $rel }
                        }
                    } }
    mhr        = @{ Id = '3771413185'; Index = 'MinorHeroesReimaginedESGPST.xml'; IndexAs = $null; KeepIcon = $false; Extra = @{}
                    Rename = {
                        param($rel)
                        $rel = $rel -replace '\[MinorHeroesReimaginedESGPST\]', '[MHR]'
                        switch -Regex ($rel) {
                            '^GalaxyGenerator\\WeightTableDefinitions\.xml$'          { return 'Galaxy\WeightTableDefinitions[MHR_MinorFactions].xml' }
                            '^GalaxyGenerator\\WeightTableDefinitions\[MHR\]\.xml$'   { return 'Galaxy\WeightTableDefinitions[MHR].xml' }
                            '^Gui\\GUIElements\[HeroSkills\]\.xml$'                  { return 'GUI\GUIElements[MHR_HeroSkills].xml' }
                            '^Gui\\GuiElements\[MHR\]\.xml$'                         { return 'GUI\GUIElements[MHR].xml' }
                            '^Gui\\GuiElements\[(.+)\]\.xml$'                         { return "GUI\GUIElements[MHR_$($Matches[1])].xml" }
                            '^Localization\\([^\\]+)\\(ES2_Localization_.+)\.xml$'   { return "Localization\$($Matches[1])\$($Matches[2])[MHR].xml" }
                            '^Simulation\\Battles\\(.+)\[MHR\]\.xml$'               { return "Simulation\Battles\$($Matches[1])[MHR].xml" }
                            '^Simulation\\ConstructibleElement_Industry\[(.+)\]\.xml$' { return "Simulation\ConstructibleElement_Industry[MHR_$($Matches[1])].xml" }
                            '^Simulation\\EntityActions\[(.+)\]\.xml$'                { return "Simulation\EntityActions[MHR_$($Matches[1])].xml" }
                            '^Simulation\\FactionTraits\[MHR\]\.xml$'                 { return 'Simulation\FactionTraits[MHR].xml' }
                            '^Simulation\\FactionTraits\[(.+)\]\.xml$'                { return "Simulation\FactionTraits[MHR_$($Matches[1])].xml" }
                            '^Simulation\\Factions\[Minor\]\.xml$'                    { return 'Simulation\Factions[MHR].xml' }
                            '^Simulation\\HeroAffinityDefinitions\[MHR\]\.xml$'       { return 'Simulation\HeroAffinityDefinitions[MHR].xml' }
                            '^Simulation\\HeroAffinityDefinitions\[(.+)\]\.xml$'      { return "Simulation\HeroAffinityDefinitions[MHR_$($Matches[1])].xml" }
                            '^Simulation\\HeroDefinitions\.xml$'                      { return 'Simulation\HeroDefinitions[MHR_Base].xml' }
                            '^Simulation\\HeroDefinitions\[(.+)\]\.xml$'              { return "Simulation\HeroDefinitions[MHR_$($Matches[1])].xml" }
                            '^Simulation\\PopulationModifiersTraits\[CollectionBonus\]\.xml$' { return 'Simulation\PopulationCollectionBonusTraits[MHR].xml' }
                            '^Simulation\\PopulationModifiersTraits\[(.+)\]\.xml$'    { return "Simulation\Traits\PopulationModifiersTraits[MHR_$($Matches[1])].xml" }
                            '^Simulation\\SimulationDescriptors\[MHR\]\.xml$'         { return 'Simulation\SimulationDescriptors[MHR].xml' }
                            '^Simulation\\SimulationDescriptors\[(.+)\]\.xml$'        { return "Simulation\SimulationDescriptors[MHR_$($Matches[1])].xml" }
                            default                                                   { return $rel }
                        }
                    } }
}
$AlwaysSkip = @('PublishedFile.Id', '.DS_Store', 'Thumbs.db', 'ASASA.jpg')
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
        elseif (($rel -eq 'ModIcon.png' -or $rel -eq $m.Icon) -and -not $m.KeepIcon) { continue }
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
