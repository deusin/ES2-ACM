# Amradyr Collective Mods (ACM) for Endless Space 2

A personal modpack that merges mods which are incompatible by default — they redefine the same
definitions, and ES2 resolves duplicates by load order (last loaded wins each definition wholesale,
no merging). So the merged definitions have to be authored somewhere; this repo is that somewhere.

Merged in (credit to the original authors — I resolve conflicts and fix bugs):

| Mod | Workshop | Imported drop | Vendor branch |
|---|---|---|---|
| **ESG Mod 1.6** (Endless Space Gaming) — the base | [2828917317](https://steamcommunity.com/sharedfiles/filedetails/?id=2828917317) | 2026-05-31 | `upstream/esg` |
| **Useful Skill Colours [ESG] 2.2** (mdel) | [3384708155](https://steamcommunity.com/sharedfiles/filedetails/?id=3384708155) | 2026-07-26 | `upstream/usc` |
| **More Traits** (Redraluin), incl. fixes | [932777803](https://steamcommunity.com/sharedfiles/filedetails/?id=932777803) | 2018-01-09 | `upstream/moretraits` |
| **Political Skill Trees** | [2856109167](https://steamcommunity.com/sharedfiles/filedetails/?id=2856109167) | 2024-10-19 | `upstream/poltrees` |
| **Endless Legend Populations 4.5** (Captain Cobbs) — twelve Endless Legend races (plus the Urkan) as minor factions; `*[ELP]*` files | [1816492263](https://steamcommunity.com/sharedfiles/filedetails/?id=1816492263) | 2024-11-26 | `upstream/elp` |
| **Minor Heroes Reimagined [ESG+PST] 0.2** (mdel) — a skill tree per minor-faction hero, Plocynos minor faction; `*[MHR]*` files | [3771413185](https://steamcommunity.com/sharedfiles/filedetails/?id=3771413185) | 2026-07-25 | `upstream/mhr` |
| Eldritch faction trait category | own content | | |

Each vendor branch holds the pristine workshop drop exactly as downloaded (before any ACM patching), so the
original files are always in the repo's history without adding anything to the mod folder. The workshop
links are the place to check for updates; `.\tools\Check-Upstream.ps1` does it for all of them at once
(asks the Steam API for each item's last-update time and compares with the imported drop — no download).

## Play set

Enable ACM plus these workshop mods. Mods not listed here (More Traits, Political Skill Trees,
Useful Skill Colours, the quest example) are already inside ACM or unwanted — leave them disabled.

| Mod | Workshop id | Overlap with ACM (`tools/Find-Conflicts.ps1`) | Notes |
|---|---|---|---|
| Samus Aran | [3268328942](https://steamcommunity.com/sharedfiles/filedetails/?id=3268328942) | `AffinityMappingTerrans` only | **Required**: ACM's `FactionTraitEldritchHero` recruits `Samus`. Load **before** ACM so ACM's Terran affinity (with ESG's mercenary ship designs) wins; Samus then comes via the Eldritch trait, not automatically to Terrans. If it loads after ACM, Terrans get her but lose the 8 mercenary designs. |
| Arkon Portal | [1788325573](https://steamcommunity.com/sharedfiles/filedetails/?id=1788325573) | none | clean extension |
| Endless Legend Populations | [1816492263](https://steamcommunity.com/sharedfiles/filedetails/?id=1816492263) | 27 `FactionTrait` + `ClassColonizedStarSystem` | **Do not use the workshop item** — its `ClassColonizedStarSystem` replaces ESG's and the game crashes on the first colonisation (`ColonizationThresholdFIDSBonus` missing). ELP is already inside ACM. |
| Minor Heroes Reimagined [ESG+PST] | [3771413185](https://steamcommunity.com/sharedfiles/filedetails/?id=3771413185) | 38 `HeroDefinition`, `MinorFactions` table, USC GUI | Already inside ACM — do not run the workshop item as well. |
| Endless Moons | [1316786885](https://steamcommunity.com/sharedfiles/filedetails/?id=1316786885) | 90 (75 descriptors, 6 anomaly reductions, 3 weight tables, 2 anomalies, 2 improvements) | |
| Endless Anomalies | [3257341334](https://steamcommunity.com/sharedfiles/filedetails/?id=3257341334) | 126 (51 `AnomalyDefinition`, 73 descriptors, 2 weight tables) | its own note: load **after** Endless Moons |
| Arkon Faction Hero Ships [ESG] | [3175229111](https://steamcommunity.com/sharedfiles/filedetails/?id=3175229111) | all 97 `HeroDefinition`s | built on ESG 1.5 hero defs; loading it after ACM replaces ESG 1.6's hero definitions with Arkon's versions |

Overlap counts are the definitions the later-loaded mod will override. Re-run the checker after any
upstream refresh; the full report with names is one command away.

## Endless Legend Populations inside ACM

ELP is merged into ACM's own folders: every file carries an `[ELP]` suffix (`Simulation/Factions[ELP].xml`,
`GUI/GUIElements[ELP_*].xml`, `Simulation/Traits/PopulationModifiersTraits[ELP*].xml`, …) so it sits next to
ESG's files without replacing any, and `ACM.xml` declares the two plugins ESG lacks
(`MinorFactionPersonalityDefinition`, `FleetNameMappingDefinition`). It is always on — ES2 has no data hook
that would let a New Game option add or remove minor factions (the galaxy generator takes every
`MinorFaction` in the database, filtered only by DLC ownership, and draws from the fixed `MinorFactions`
weight table). If you ever want a game without them, use a git branch.

Changes against the workshop drop (redo on each `upstream/elp` merge):

| Where | What |
|---|---|
| `Simulation/SimulationDescriptors[ELP_ColonizedStarSystem].xml` | deleted — it replaced ESG's `ClassColonizedStarSystem` and crashed on the first colonisation; ESG 1.6 already carries the one property it added (`OnGoingLords`). |
| `Simulation/FactionTraits[ELP_Minor].xml` | its copies of the 27 vanilla starting-minor-pop traits removed (ESG's apply); ELP's own twelve use ESG's prerequisites (starting-pop traits may stack). |
| `Simulation/SimulationDescriptors[ELP_PopulationCollectionBonus].xml` | Mykara tier 2 pathed to Morgawr pops → Mykara; Morgawr tier 1 pushed politics through the Necrophage descriptor → Morgawr. |
| `Simulation/SimulationDescriptors[ELP_PopulationModifierTraits].xml` | `$(PlanetIsTeemings)` typo (Wild Walkers); Morgawr fertile-planet influence written as a non-binary modifier → `BinaryModifier`. |
| `Localization/brazilian`, `Localization/polish` | English copies of the two ELP locale files (ELP ships none for those languages). |

## Minor Heroes Reimagined inside ACM

Same pattern as ELP: the drop's new content is renamed with an `[MHR]` suffix (`Simulation/HeroSkillDefinitions[MHR].xml`,
`Simulation/HeroSkillTreeDefinitions[MHR].xml`, `GUI/GUIElements[MHR*].xml`, `Simulation/Factions[MHR].xml`, …); `ACM.xml`
gained wildcards for hero skills/trees, entity actions and ship conditional effects plus a `HeroAffinityDefinition`
plugin. The drop also ships partial copies of ESG/USC files; those are grafted and the copies deleted:

| Drop file (as imported) | What was done |
|---|---|
| `Simulation/HeroDefinitions[MHR_*].xml` (8 files) | the 38 minor-faction heroes replaced by name inside ACM's `HeroDefinitions.xml` (new affinity + faction skill tree, innate skill removed; the Political Skill Trees politics tree is kept). Files deleted. |
| `Simulation/ConstructibleElement_Industry[MHR_PlanetColonization].xml` | the only delta — `./ClassColonizedStarSystem,FreeColonization` added to the `MetaPrerequisite` of 29 colonisation entries — grafted into ACM's file. Deleted. |
| `Galaxy/WeightTableDefinitions[MHR_MinorFactions].xml` | ES2 keeps one `MinorFactions` table, so ACM now owns it in `Galaxy/WeightTableDefinitions[ACM_MinorFactions].xml` (vanilla 27 + ELP 12 + Plocynos); removed from the `[ELP]` file. Deleted. |
| `GUI/GUIElements[MHR_Extended].xml` | Useful Skill Colours 2.2 (same author) already carries 154 of these elements with tinted icons; only the 151 USC lacks are kept. |
| `GUI/GUIElements[MHR_HeroSkills].xml` | one untinted icon; USC's wins. Deleted. |
| `Localization/<lang>/…[MHR].xml` | English copied to the six other languages (the mod is English-only). |

Burra Techseeker (the Plocynos hero) needs the Community Challenge Addon DLC, as upstream.

## Working on the mod

- This folder is the git working tree **and** the folder ES2 loads (`Documents\Endless Space 2\Community`).
  The `.git` file points at the object store in `C:\Users\Kenny\source\repos\ES2-ACM.git`; edit → save →
  launch the game, no copy step.
- Is anything out of date? `.\tools\Check-Upstream.ps1` (`-Notes` adds the authors' change notes newer than our
  drop). It needs no downloads, so the folded-in workshop items can stay unsubscribed; resubscribe one only to
  refresh it.
- Refreshing an upstream mod: resubscribe so Steam downloads it, `.\tools\Import-Upstream.ps1 -Mod <esg|usc|moretraits|poltrees|elp|mhr>`, then
  `git merge upstream/esg`. `elp` / `mhr` imports land the drop on the `[ELP]` / `[MHR]` paths above.
  Details, conflict conventions and gotchas are in `CLAUDE.md`.
- `.\tools\Find-Conflicts.ps1 -Mod <workshop id>` reports which definitions a workshop mod shares with ACM.

## History

- 2025-02: ESG 1.6 import; More Traits, Political Skill Trees, Useful Skill Colours integrated; Eldritch + Samus added.
- 2026-08: repo relocated into the Community folder; vendor branches + import tooling; ESG refreshed to the
  2026-05-31 drop (267 changed files, 4 conflicts); USC 2.2 grafted in; Samus removed in favour of the
  workshop mod (its skill trees had been copied into the `[Eldritch]` files). Endless Legend
  Populations 4.5 merged in (renamed `[ELP]` files, four data fixes) after the workshop item crashed game start. Minor Heroes Reimagined
  [ESG+PST] 0.2 merged in the same way.
