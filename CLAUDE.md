# ES2 ACM — Amradyr Collective Mods

Personal fork-and-merge modpack for Endless Space 2 (Kenny + their son). ESG is the base; other
mods that are incompatible with it (they redefine the same definitions) are merged in by hand.
Start Claude Code sessions **from this folder**.

## Layout and locations

- **This folder is both the git working tree and the folder the game loads.** The `.git` here is a
  pointer file; the object store lives outside OneDrive at `C:\Users\Kenny\source\repos\ES2-ACM.git`.
  Never move or sync that directory into OneDrive.
- Remote: `https://github.com/deusin/ES2-ACM` (branch `master`).
- Mod index: `ACM.xml` (ESG's `ESCM.xml` renamed). Module name `ACM`, workshop id in `PublishedFile.Id`.
- Steam Workshop downloads (the only upstream source — ESG's GitHub repo died in 2022):
  `D:\SteamLibrary\steamapps\workshop\content\392110\<id>`; update times in
  `D:\SteamLibrary\steamapps\workshop\appworkshop_392110.acf` (`timeupdated`).

| Mod | Workshop id | Role |
|---|---|---|
| ESG 1.6 | 2828917317 | base, merged (index `ESCM.xml`) |
| Useful Skill Colours [ESG] | 3384708155 | merged |
| More Traits | 932777803 | merged |
| Political Skill Trees | 2856109167 | merged |
| Samus Aran | 3268328942 | **run alongside** (ACM's Eldritch hero trait recruits `Samus`) |
| Endless Moons | 1316786885 | run alongside (see README for overlaps) |
| Endless Anomalies | 3257341334 | run alongside, load after Endless Moons |
| Endless Legend Populations | 1816492263 | run alongside |
| Arkon Portal | 1788325573 | run alongside, no overlaps |
| Arkon Faction Hero Ships [ESG] | 3175229111 | run alongside (overrides all HeroDefinitions) |

## Lifecycle: refreshing an upstream mod

Vendor branches `upstream/esg`, `upstream/usc` (create `upstream/moretraits` / `upstream/poltrees`
from their integration commits `a337329` / `1ea078a` only if those mods ever update).

```
.\tools\Import-Upstream.ps1 -Mod esg     # copies the workshop drop onto upstream/esg and commits
git merge upstream/esg                    # 3-way merge into master; resolve only real conflicts
```

- The import script records what it copied in `tools/upstream-manifests/<mod>.txt` so files removed
  upstream get deleted. It renames ESG's `ESCM.xml` to `ACM.xml`; for other mods the index XML is
  *not* imported (a second RuntimeModule XML would register a second mod).
- `ACM.xml` header (Name/Title/Author/PreviewImageFile) always conflicts on ESG merges: keep ours.
- **USC's `Simulation/HeroSkillDefinitions.xml` and `GUI/GUIElements[HeroSkills].xml` are partial
  overrides of ESG files that ACM carries in full at the same paths. Never take them wholesale** — it
  would drop the ESG definitions USC omits. Compare semantically (per skill level: descriptor refs +
  MasteryLevel; per GUI element: icon paths) and graft USC's deltas into ACM's copies. USC's
  DLC-split `HeroSkillDefinitions[DLC*|Update8].xml` and `SimulationDescriptors[HeroSkill].xml` are
  deleted on master; a modify/delete conflict on them is the cue to redo that comparison.
- `Gui/GuiElements[Extended].xml` must stay the **last** FilePath in the GuiElement plugin in
  `ACM.xml` or Political Skill Tree colouring breaks.
- `.\tools\Find-Conflicts.ps1 -Mod <id>` lists definitions a workshop mod shares with ACM
  (later-loaded mod wins each wholesale). Use it before adding a mod to the play set or merging one.

## Gotchas

- Mod file names contain `[brackets]`. In PowerShell always use `-LiteralPath`; `Get-FileHash`,
  `Copy-Item`, `Test-Path` etc. silently misbehave otherwise. Python on Windows needs `C:\` paths.
- `.gitattributes` is `* text=auto eol=crlf`: blobs LF, working tree CRLF. Workshop drops are mixed
  (ESG CRLF, USC LF) — don't change this or every import shows whole-file diffs.
- ESG reuses `SkillLevel` names across different `HeroSkillDefinition`s (e.g. `HeroSkill01BranchHoratio_01`
  under `HeroSkill03..08BranchHoratio`); key comparisons by (skill, level), not level alone.
- ES2 resolves duplicate definitions by load order at whole-definition granularity; it does not merge.
- Validation without launching the game: parse every `*.xml` (all must be well-formed) and check every
  `Bitmaps/Dynamic/...` icon path has a PNG under `Resources/`. In-game: Mods menu → enable the play
  set → new game → no red load errors; check `Documents\Endless Space 2\Temporary Files` for XML errors.
