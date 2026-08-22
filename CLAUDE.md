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
| ESG 1.6 | [2828917317](https://steamcommunity.com/sharedfiles/filedetails/?id=2828917317) | base, merged (index `ESCM.xml`) |
| Useful Skill Colours [ESG] | [3384708155](https://steamcommunity.com/sharedfiles/filedetails/?id=3384708155) | merged |
| More Traits (`upstream/moretraits`) | [932777803](https://steamcommunity.com/sharedfiles/filedetails/?id=932777803) | merged |
| Political Skill Trees (`upstream/poltrees`) | [2856109167](https://steamcommunity.com/sharedfiles/filedetails/?id=2856109167) | merged |
| Samus Aran | [3268328942](https://steamcommunity.com/sharedfiles/filedetails/?id=3268328942) | merged as `*[Samus]*` files (vendor branch `upstream/samus`), gated by the `EnableSamus` New Game setting; never also run the workshop item |
| Endless Moons | [1316786885](https://steamcommunity.com/sharedfiles/filedetails/?id=1316786885) | merged as `*[EM]*` files (vendor branch `upstream/em`), always on; merge policy in README |
| Endless Anomalies | [3257341334](https://steamcommunity.com/sharedfiles/filedetails/?id=3257341334) | merged as `*[EA]*` files (vendor branch `upstream/ea`), always on; merge policy in README |
| Endless Legend Populations | [1816492263](https://steamcommunity.com/sharedfiles/filedetails/?id=1816492263) | merged as `*[ELP]*` files (vendor branch `upstream/elp`); never also run the workshop item — its `ClassColonizedStarSystem` crashes ACM |
| Minor Heroes Reimagined [ESG+PST] | [3771413185](https://steamcommunity.com/sharedfiles/filedetails/?id=3771413185) | merged as `*[MHR]*` files (vendor branch `upstream/mhr`); partial ESG/USC copies grafted, see README |
| Arkon Portal | [1788325573](https://steamcommunity.com/sharedfiles/filedetails/?id=1788325573) | merged as `*[Arkon]*` files (vendor branch `upstream/arkonportal`), gated by `EnableArkonPortal`; 500-point trait dropped; never also run the workshop item |
| Arkon Faction Hero Ships [ESG] | [3175229111](https://steamcommunity.com/sharedfiles/filedetails/?id=3175229111) | merged as `*[AFHS]*` files (vendor branch `upstream/afhs`), always on; never also run the workshop item |

## Lifecycle: refreshing an upstream mod

Vendor branches `upstream/<mod>` for esg, usc, moretraits, poltrees, elp, mhr, samus, arkonportal, afhs, em, ea hold the pristine workshop
drops (moretraits/poltrees were baselined with `git merge -s ours`, so their next import merges 3-way).
`.\tools\Check-Upstream.ps1` asks the Steam API which of them has updated since its last import (`-Notes`
prints the workshop change notes newer than the drop; fetch Steam pages directly with curl/Invoke-WebRequest,
the WebFetch proxy gets 429 from Steam). The user keeps folded-in items unsubscribed: the files only arrive
via a Steam download, so ask them to resubscribe before an import. `git diff upstream/<mod>~1 upstream/<mod>`
shows what changed between drops.

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
- **ELP** files are renamed on import with an `[ELP]` suffix (mapping = the `Rename` block in
  `Import-Upstream.ps1`; they must match a `FilePath` pattern in `ACM.xml`). Master's patches on top
  of the drop are listed in the README table ("Endless Legend Populations inside ACM") — redo them
  on every `upstream/elp` merge; a modify/delete conflict on
  `SimulationDescriptors[ELP_ColonizedStarSystem].xml` means keep it deleted.
- **MHR** (same shape as ELP, suffix `[MHR]`). The drop's `HeroDefinitions[MHR_*]`,
  `ConstructibleElement_Industry[MHR_PlanetColonization]`, `WeightTableDefinitions[MHR_MinorFactions]`,
  `GUIElements[MHR_HeroSkills]` are partial copies of ESG/USC files — graft per the README table, then
  delete (modify/delete conflicts on them are the cue). `GUIElements[MHR_Extended]` keeps only what
  `Gui/GuiElements[Extended].xml` (USC) lacks. The `MinorFactions` weight table is ACM-owned in
  `Galaxy/WeightTableDefinitions[ACM_MinorFactions].xml`; every merged mod that adds a minor faction
  must be listed there (a later-loaded copy of the table replaces it wholesale).
- **Samus** (suffix `[Samus]`). Delete the drop's `FactionTraits[Samus].xml` (Terran affinity; ESG's with the
  mercenary designs wins) and the empty `ES2_Localization_Assets_Locales[Samus].xml`; keep the
  `GameSettingPrerequisite` on `HeroDefinitions[Samus].xml` (modify/delete conflicts are the cue).
- **Arkon Portal** (suffix `[Arkon]`). On every `upstream/arkonportal` merge re-remove `FactionTraitPPOINTS` (trait,
  descriptor, GUI element, `PPOINTS` locale lines, `500_Trait_Points.png`) and keep the `EnableArkonPortal`
  prerequisites on `ConstructibleElement_Industry[Arkon]` / `ConstructibleElement_Science[Arkon]`.
- **AFHS** (suffix `[AFHS]`, files under `Simulation/Battles/`). The drop's `HeroDefinitions[AFHS_Heroes].xml` is a
  full ESG-1.5 copy of all 97 heroes: graft only each hero's `<ShipDesign>` into `Simulation/HeroDefinitions.xml`
  (and ESG merges must keep those `AFHER*` references), then delete it (modify/delete conflict = the cue). Not
  toggleable: a hero has one `ShipDesign` reference and the client fails the recruit order if it is missing.
- **EM / EA** (suffixes `[EM]`, `[EA]`). Vanilla anomalies stay ESG's, moon mechanics are EM's, the three anomaly
  weight tables are ACM-owned in `Galaxy/WeightTableDefinitions[ACM_Anomalies].xml`, galaxy sizes are ESG's with EM's
  anomaly counts — the README table lists every deleted/trimmed drop file; modify/delete conflicts on them are the cue.
- **ACM New Game toggles** live in `Settings/GameSettingDefinitions[ACM].xml` + `GUI/GUIElements[ACM_Settings].xml`
  + `Localization/english/ES2_Localization_Locales[ACM].xml`, and the `AdvancedSettingsACMSettings` group in
  `GUI/Screens/GUIElements[NewGameScreen].xml` (an ESG file, single definition — re-add the group after every ESG
  merge). Prerequisite form: `<GameSettingPrerequisite Flags="Prerequisite,Discard">EnableSamus,True</GameSettingPrerequisite>`.
  Decompiled `Academy.Initialize` evaluates hero prerequisites once at galaxy creation (off = not in the Academy
  pool; the hero stays in the database, so `RecruitHero` commands such as `FactionTraitEldritchHero` still work).
- **No game-setting toggle for factions.** `GameSettingPrerequisite` works on
  constructibles/techs/quests/diplomacy only. `FactionTrait`/`MinorFaction` take string path
  prerequisites, descriptors and weight tables none; the galaxy generator (`GameManager` →
  `Generator.EmpiresManager`) adds every `MinorFaction` filtered only by DLC and draws from the fixed
  `MinorFactions` table. Decided 2026-08-22 after decompiling; don't re-investigate. **Heroes are different:**
  `HeroDefinition.xsd` accepts `GameSettingPrerequisite`, so a hero folded into ACM (e.g. Samus) can be
  gated by a New Game setting (add a `GameSettingDefinition` + localisation, as ESG's `LawRework`).
  The schemas in `Public\Schemas\*.xsd` are the authority on which definition types take it.
- **Addon modules** (a second RuntimeModule folder junctioned into `Community\`) work if ever needed:
  `RuntimeModule Name` must be alphanumeric (ES2 logs `Invalid runtime module name`, discards it), the
  module shows in the main-menu Mods screen, not New Game. When a module is missing, grep
  `Temporary Files\Diagnostics*.html` for `runtime module`.

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
