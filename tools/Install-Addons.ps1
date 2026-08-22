#requires -Version 5.1
<#
.SYNOPSIS
  Expose the addon modules under Addons\ to Endless Space 2 as separate, toggleable mods.

.DESCRIPTION
  ES2 only registers mods that sit directly under Documents\Endless Space 2\Community\<folder>.
  ACM keeps optional modules (patched third-party mods that would conflict with ACM as-is) in
  Addons\<name>\ inside this repo. This script creates a directory junction
  Community\<name> -> <repo>\Addons\<name> for each of them, so the game lists them in the Mods
  menu next to ACM and they can be enabled per play set. Junctions need no admin rights and are
  ignored by OneDrive (the content is synced once, via the repo).

  Run it once after cloning, and again whenever an addon is added. -Remove deletes the junctions
  (the repo content is untouched).

.EXAMPLE
  .\tools\Install-Addons.ps1
  .\tools\Install-Addons.ps1 -Remove
#>
[CmdletBinding()]
param(
    [switch]$Remove
)

$ErrorActionPreference = 'Stop'
$RepoRoot      = Split-Path $PSScriptRoot -Parent
$AddonsRoot    = Join-Path $RepoRoot 'Addons'
$CommunityRoot = Split-Path $RepoRoot -Parent

if (-not (Test-Path -LiteralPath $AddonsRoot)) { Write-Host "No Addons folder in $RepoRoot"; return }

foreach ($addon in (Get-ChildItem -LiteralPath $AddonsRoot -Directory)) {
    $link = Join-Path $CommunityRoot $addon.Name
    $item = Get-Item -LiteralPath $link -ErrorAction SilentlyContinue

    if ($Remove) {
        if ($null -eq $item) { Write-Host "$($addon.Name): not installed"; continue }
        if (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            Write-Warning "$link is a real folder, not a junction - leaving it alone."; continue
        }
        # rmdir on a junction removes only the link, never the target's content.
        cmd /c rmdir "$link" | Out-Null
        Write-Host "$($addon.Name): junction removed"
        continue
    }

    if ($null -ne $item) {
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            Write-Host "$($addon.Name): already installed -> $link"
        }
        else {
            Write-Warning "$link exists and is a real folder (a workshop copy?). Remove or rename it, then rerun."
        }
        continue
    }
    cmd /c mklink /J "$link" "$($addon.FullName)" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "mklink failed for $link" }
    Write-Host "$($addon.Name): installed -> $link"
}

if (-not $Remove) {
    Write-Host ''
    Write-Host 'Addons appear in the in-game Mods menu by their own title; enable them after ACM.'
}
