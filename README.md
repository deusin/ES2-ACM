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
| **Samus Aran 1.0** (Ghoulvarine) — Terran admiral with her own skill trees; `*[Samus]*` files, New Game toggle | [3268328942](https://steamcommunity.com/sharedfiles/filedetails/?id=3268328942) | 2025-05-31 | `upstream/samus` |
| **Arkon Portal** (Arkon) — custom-faction trait for fleet-teleportation portals; `*[Arkon]*` files, New Game toggle | [1788325573](https://steamcommunity.com/sharedfiles/filedetails/?id=1788325573) | 2019-09-04 | `upstream/arkonportal` |
| **Arkon Faction Hero Ships [ESG] 1.0.4** (Arkon) — heroes fly medium faction ships; `*[AFHS]*` files | [3175229111](https://steamcommunity.com/sharedfiles/filedetails/?id=3175229111) | 2025-12-17 | `upstream/afhs` |
| **Endless Moons 3.1.2** (Tychonoir) — many moon types, lunar improvements, moon temples and celestial orbs; `*[EM]*` files | [1316786885](https://steamcommunity.com/sharedfiles/filedetails/?id=1316786885) | 2024-11-11 | `upstream/em` |
| **Endless Anomalies 1.1.3** — over 100 new anomalies; `*[EA]*` files | [3257341334](https://steamcommunity.com/sharedfiles/filedetails/?id=3257341334) | 2024-11-13 | `upstream/ea` |
| **Deep Space Mining 1.3.6** — special nodes that yield strategic resources; `*[DSM]*` files | [1263186686](https://steamcommunity.com/sharedfiles/filedetails/?id=1263186686) | 2019-04-28 | `upstream/dsm` |
| **Worthy Deeds 0.33** (tygart) — deeds for every empire, all rewards; `*[WD]*` files, `Enable Worthy Deeds` toggle | [1587659427](https://steamcommunity.com/sharedfiles/filedetails/?id=1587659427) | 2020-10-28 | `upstream/worthydeeds` |
| **Kaizen Rejuvenation 1.2.0** (fb.aazzoggerr) — infinite improvement that reverses Cravers planet depletion; `*[Kaizen]*` files, `Enable Kaizen Rejuvenation` toggle | [1130687397](https://steamcommunity.com/sharedfiles/filedetails/?id=1130687397) | 2018-01-26 | `upstream/kaizen` |
| Eldritch faction trait category | own content | | |

Each vendor branch holds the pristine workshop drop exactly as downloaded (before any ACM patching), so the
original files are always in the repo's history without adding anything to the mod folder. The workshop
links are the place to check for updates; `.\tools\Check-Upstream.ps1` does it for all of them at once
(asks the Steam API for each item's last-update time and compares with the imported drop — no download).

## Play set

Everything listed below is now inside ACM: enable **ACM alone**. (More Traits, Political Skill Trees, Useful Skill
Colours and the quest example are also inside or unwanted — leave every workshop item disabled.)

| Mod | Workshop id | Overlap with ACM (`tools/Find-Conflicts.ps1`) | Notes |
|---|---|---|---|
| Samus Aran | [3268328942](https://steamcommunity.com/sharedfiles/filedetails/?id=3268328942) | `AffinityMappingTerrans`, all Samus definitions | Already inside ACM (with a New Game toggle) — do not run the workshop item as well; loaded after ACM it would give Terrans Samus but take away ESG's 8 mercenary ship designs. |
| Arkon Portal | [1788325573](https://steamcommunity.com/sharedfiles/filedetails/?id=1788325573) | all its definitions | Already inside ACM (with a New Game toggle) — do not run the workshop item as well; it would bring the 500-point trait back. |
| Endless Legend Populations | [1816492263](https://steamcommunity.com/sharedfiles/filedetails/?id=1816492263) | 27 `FactionTrait` + `ClassColonizedStarSystem` | **Do not use the workshop item** — its `ClassColonizedStarSystem` replaces ESG's and the game crashes on the first colonisation (`ColonizationThresholdFIDSBonus` missing). ELP is already inside ACM. |
| Minor Heroes Reimagined [ESG+PST] | [3771413185](https://steamcommunity.com/sharedfiles/filedetails/?id=3771413185) | 38 `HeroDefinition`, `MinorFactions` table, USC GUI | Already inside ACM — do not run the workshop item as well. |
| Endless Moons | [1316786885](https://steamcommunity.com/sharedfiles/filedetails/?id=1316786885) | 90 (vanilla anomalies, 3 weight tables, moon improvements, galaxy sizes) | Already inside ACM — do not run the workshop item as well. |
| Endless Anomalies | [3257341334](https://steamcommunity.com/sharedfiles/filedetails/?id=3257341334) | 126 (51 vanilla anomalies, 73 descriptors, 2 weight tables) | Already inside ACM — do not run the workshop item as well. |
| Arkon Faction Hero Ships [ESG] | [3175229111](https://steamcommunity.com/sharedfiles/filedetails/?id=3175229111) | all 97 `HeroDefinition`s | Already inside ACM — do not run the workshop item as well; loaded after ACM it replaces every hero with its ESG 1.5 copy (no Political Skill Trees / Minor Heroes Reimagined trees). |

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

## Samus Aran inside ACM

The drop's files carry a `[Samus]` suffix (`Simulation/HeroDefinitions[Samus].xml`, `…HeroSkillDefinitions[Samus].xml`,
`…HeroSkillTreeDefinitions[Samus].xml`, `…SimulationDescriptors[Samus].xml`, `GUI/GUIElements[Samus].xml`,
`Localization/english/ES2_Localization_Locales[Samus].xml`, three portraits under `Resources/Gui`).

| Drop file (as imported) | What was done |
|---|---|
| `Simulation/FactionTraits[Samus].xml` | deleted — it is the upstream Terran affinity with `RecruitHero Samus` added; ACM keeps ESG's affinity (8 mercenary ship designs). Samus is recruited from the Academy like any hero, or directly via the Eldritch Hero faction trait. |
| `Localization/english/ES2_Localization_Assets_Locales[Samus].xml` | deleted (empty). |
| `Simulation/HeroDefinitions[Samus].xml` | `<GameSettingPrerequisite>EnableSamus,True</GameSettingPrerequisite>` added. |

**New Game › Advanced › ACM Settings › Enable Samus Aran** (default on). Off, she never enters the Academy pool; the
setting is fixed for the game once started. The Eldritch Hero faction trait recruits her by name regardless of the
setting (faction traits cannot see game settings). The toggle is the template for further ACM toggles: a
`GameSettingDefinition` in `Settings/GameSettingDefinitions[ACM].xml`, an `Entry` in the `AdvancedSettingsACMSettings`
group of `GUI/Screens/GUIElements[NewGameScreen].xml` (an ESG file — re-add the group on every ESG merge),
`Setting<Name>` / `<Name>True` / `<Name>False` elements in `GUI/GUIElements[ACM_Settings].xml`, strings in
`Localization/english/ES2_Localization_Locales[ACM].xml`, and a `GameSettingPrerequisite` on the gated definitions.

## Arkon Portal inside ACM

Files carry an `[Arkon]` suffix; the drop's `StarSYSImpro[PORTAL].xml` / `TechnologyDefinitions[PORTAL].xml` land on ACM's
`Simulation/ConstructibleElement_Industry[Arkon].xml` / `ConstructibleElement_Science[Arkon].xml` paths. Two files were
re-encoded from windows-1250 to UTF-8.

| What | Where |
|---|---|
| `FactionTraitPPOINTS` ("ARK - POINT GIVER", cost −500) removed: trait, descriptor, GUI element, strings in all six languages, `Resources/Textures/500_Trait_Points.png`. | `FactionTraits[Arkon]`, `SimulationDescriptors[Arkon]`, `GUI/GUIElements[Arkon]`, `Localization/*/…[Arkon]` |
| `EnableArkonPortal,True` `GameSettingPrerequisite` on the `JumpPortal` improvement and the hidden `TechnologyLinkDefinitionArkPortalTEC`. | `ConstructibleElement_Industry[Arkon]`, `ConstructibleElement_Science[Arkon]` |
| Trait tooltip pointed at the undefined `%FactionTraitStartingTechnologyEffectOverride`; now shows the trait's own effect text. | `GUI/GUIElements[Arkon]` |

**New Game › Advanced › ACM Settings › Enable Arkon Portal** (default on). Off, the portal improvement and its tech are
discarded; the "ARK - Teleportation portal" trait stays selectable in the faction editor (faction traits cannot see game
settings) but then does nothing.

## Arkon Faction Hero Ships inside ACM

Hulls, ship designs, design templates, battle action, descriptors, GUI, droplists and strings carry an `[AFHS]` suffix
(`Simulation/Battles/*[AFHS].xml`, `GUI/GUIElements[AFHS].xml`, `Quests/Droplists/Droplists[AFHS].xml`, …); `ACM.xml`
gained a `ShipDesignTemplateDefinition` plugin. The drop's `HeroDefinition` file (all 97 heroes, built on ESG 1.5) is
not kept: only each hero's `<ShipDesign>` reference is grafted into ACM's `Simulation/HeroDefinitions.xml`, and Samus
gets `AFHERTerrans_MediumAttacker`. Its `HeroShip_Revive` battle action and two Academy-quest droplists replace the
vanilla ones on purpose (hero faction ships must revive too). Seven files re-encoded from windows-1250 to UTF-8.
One icon path typo fixed (`UNF_RXP_Large` → `UNF_EXP_Large`, Unfallen explorer hull).
The english, french and spanish string files had stray Latin-1 bytes (not well-formed XML — the game would have dropped the whole file); re-saved as UTF-8.
Always on — a hero has a single ship reference, so there is nothing a New Game setting could switch.

## Endless Moons and Endless Anomalies inside ACM

Both mods rebalance the vanilla anomalies that ESG already reworked (ESG splits every anomaly into a base descriptor plus an
upgradeable `…Regular` one), and both carry the same anomaly weight tables. Merge policy, redone on every `em`/`ea`/`esg` merge:

| Area | Decision |
|---|---|
| Vanilla anomalies (definitions + descriptors) | **ESG's**. `SimulationDescriptors[EM_OriginalAnomalies]`, `SimulationDescriptors[EA_OriginalAnomalies]`, `AnomalyDefinitions[EA_OriginalAnomalies]` deleted; `PlanetAnomaly07/08` removed from `AnomalyDefinitions[EM]`; `PlanetAnomaly10` removed from `GuiPlanetStatsModifiers[EA]`. Endless Moons' versions of the vanilla moons 25–27 (+Alt) stay — ESG does not define them. |
| Moon mechanics | **Endless Moons'**: `AnomalyReduction25–27(+Alt)` (1-turn Explore Moon), `StarSystemImprovementMoonExploitation1` (disabled, replaced by the lunar improvements), `StarSystemImprovementPopulationSlot2` (needs a developed moon), `StarSystemImprovementCuriosity5` descriptor (15 research + 2 vision per moon). ESG's copies removed from its files. |
| `HistoricalEnclave` / `EndlessEnclave` | Endless Anomalies' (the author says to load EA after EM); removed from `[EM_StarSystemImprovements]`. |
| Anomaly weight tables | ACM-owned `Galaxy/WeightTableDefinitions[ACM_Anomalies].xml`: ESG entries + EM entries + EA entries; vanilla tags take EA's weight where EA rebalanced it, else EM's, else ESG's; the vanilla moons EM removes are removed. The three tables deleted from ESG's `WeightTableDefinitions.xml`. |
| Galaxy sizes | ESG's `WorldSettingDefinitions.xml` kept; `AnomaliesVisibleQuantity` scaled by EM's ratio to vanilla per size (×1.33 Tiny … ×2 Huge) and EM's `UniquePlanetQuantity` / `WondersMaxQuantity` added. `WorldSettingDefinitions[EM]` deleted. |
| Duplicates | `EndlessMoonsEnabled` descriptor (ESG already has it) and `PlanetAnomaly` (identical in EM and EA) removed from the EM / EA files; `CategoryAnomalyQualityMoon` keeps ESG's colour; empty `[EM_Quadrants]` tech file deleted. |

ESG carries hooks for Endless Moons (`OwnedMoons`, `EndlessMoonsEnabled`), and EM's start quest tags every empire with that
descriptor. `ACM.xml` gained `GuiTooltipDescription` and `GuiPlanetStatsModifier` plugins and an anomaly-reductions wildcard.
Endless Moons is English/German, Endless Anomalies English only.
Upstream slips fixed on the way: weight-table tags `Curiosity_CreepingAlgea` (typo) and `Curiosity_CrystallineWorld` (no such
curiosity, dropped); `ShiftingGround` referenced the undefined `AnomalyTypeGround` (→ `PlanetAnomalyGround`); `HiddenVaults_R` referenced
`CHiddenVaults_R`; `%Moon_TM_Title` (the hidden EndlessMoonsEnabled trait) was never defined.

## Deep Space Mining inside ACM

Adds 18 special-node variants (asteroid fields, black holes, collapsing/neutron stars, nebulae, hidden ones) whose effect
descriptors carry `Strategic1–6`, which the exploiting system and orbiting fleets collect. It redefines five descriptors ESG
also reworked; ACM keeps ESG's and grafts only the strategic lines:

| Drop file (as imported) | What was done |
|---|---|
| `SimulationDescriptors[DSM_SpecialNodeEffect].xml` | deleted — the six `Strategic` properties and the `AllowToExploitStrategicCommon1` force added to ESG's `ClassSpecialNodeEffect` (`[SpecialNode_Orbit]`), which keeps its FIDSI multiplier. |
| `…[DSM_SpecialNodeOrbitResources]`, `…[DSM_SpecialNodeEffectResources]` | the `SpaceClouds` / `Vaulters` entries removed; their `Strategic` modifiers added to ESG's versions in `[SpecialNode_Orbit]` / `[SpecialNode_System]`. |
| `GUI/GUIElements[DSM_Strategics].xml` | deleted — identical to vanilla. |
| `Galaxy/WeightTableDefinitions[DSM].xml` | the mod listed only its own variants; the vanilla node types (whose effects ESG rebalanced) are kept in the pool at vanilla weight; hidden table referenced `SpecialNodeBlackHoleHidden1/2`, which nothing defines → the mod's `SpecialNodeBlackHiddenHole1/2`. |
| `Localization/english/…[DSM].xml` | new — `%SpecialNodeStrategic1TooltipEffect` was used but never defined (the mod ships no strings). |

`ACM.xml` gained a `SpecialNodeDefinition` plugin. The companion "Deep Space Mining Modules" (1641490632) is not included.

## Worthy Deeds inside ACM

Worthy Deeds makes every regular Deed a per-empire quest (`QuestContextSolo`, once per empire) instead of a galaxy-wide
race, and pays out *every* item of the reward list instead of one weighted pick. The mod is a full copy of the 2020
vanilla deeds, so loaded on top of ESG it would revert ESG's deed rebalance (harder thresholds, three rewritten objectives,
wonder costs, strategic-resource rewards). ACM keeps ESG's deeds and applies the Worthy Deeds *mechanism* to them, behind
the `Enable Worthy Deeds` New Game toggle (default on):

| File | What it is |
|---|---|
| `Quests/QuestDefinitions[WD].xml` | generated: 24 `Deeds_Regular_*_WD` quests = ESG's deed (or vanilla's, for the 14 deeds ESG leaves alone) with Solo context, `$Empire` sources, `_WD` chain references, one `Reward` per split droplist, `EnableWorthyDeeds,True`; plus the 14 vanilla deeds copied with `EnableWorthyDeeds,False`. ESG's 10 deeds in `QuestDefinitions[Deeds].xml` carry the same `False` gate. |
| `Quests/Droplists/Droplists[WD].xml` | generated: the 8 deed reward droplists split into one droplist per entry (`…Bis_WD1..n`), contents from ESG's `Droplists[Reward].xml` where it redefines the list, else vanilla. |
| `GUI/GUIElements[WD].xml`, `Localization/*/…[WD].xml` | generated: `QuestGuiElement`s and the six strings of every `_WD` deed (vanilla icons; english objectives lose "Be the first to…"). |
| drop's `QuestDefinitions[WD_*]`, `ConstructibleElement_Industry[WD_Wonders]`, `SimulationDescriptors[WD]`, `GUI[WD]`, english loc | deleted — the quest bodies are stale vanilla; the wonder rework (Wonders 1/2/4 buildable once per empire, tech-unlocked, plus a Vampirilis research→lifeforce wonder) is **not** taken: wonders stay a galaxy race with ESG's costs. |

The generator is the graft script (`graft_wd.py`, kept in the session scratchpad, not the repo); after an ESG merge that
touches `QuestDefinitions[Deeds].xml` or `Droplists[Reward].xml`, regenerate the `_WD` copies rather than patching them.

## Kaizen Rejuvenation inside ACM

One infinite star-system improvement (`StarSystemImprovementKaizenRejuvenation`, non-Cravers empires, only offered while a
planet in the system is depleted) that removes depletion points at one per turn per population on each planet. Folded in as
`*[Kaizen]*` files with no changes except the `EnableKaizenRejuvenation,True` gate on the improvement (New Game toggle,
default on) and the dropped override of vanilla's `%PlanetNotDepletedTitle` string. The drop's `StarSystemImprovements.xml`
is renamed to `ConstructibleElement_Industry[Kaizen].xml` so ESG's existing `FilePath` pattern loads it.

## Working on the mod

- This folder is the git working tree **and** the folder ES2 loads (`Documents\Endless Space 2\Community`).
  The `.git` file points at the object store in `C:\Users\Kenny\source\repos\ES2-ACM.git`; edit → save →
  launch the game, no copy step.
- Is anything out of date? `.\tools\Check-Upstream.ps1` (`-Notes` adds the authors' change notes newer than our
  drop). It needs no downloads, so the folded-in workshop items can stay unsubscribed; resubscribe one only to
  refresh it.
- Refreshing an upstream mod: resubscribe so Steam downloads it, `.\tools\Import-Upstream.ps1 -Mod <esg|usc|moretraits|poltrees|elp|mhr|samus|arkonportal|afhs|em|ea|dsm>`, then
  `git merge upstream/esg`. `elp` / `mhr` / `samus` / `arkonportal` / `afhs` / `em` / `ea` / `dsm` imports land the drop on the `[ELP]` / `[MHR]` / `[Samus]` / `[Arkon]` / `[AFHS]` / `[EM]` / `[EA]` / `[DSM]` paths above.
  Details, conflict conventions and gotchas are in `CLAUDE.md`.
- `.\tools\Find-Conflicts.ps1 -Mod <workshop id>` reports which definitions a workshop mod shares with ACM.

## History

- 2025-02: ESG 1.6 import; More Traits, Political Skill Trees, Useful Skill Colours integrated; Eldritch + Samus added.
- 2026-08: repo relocated into the Community folder; vendor branches + import tooling; ESG refreshed to the
  2026-05-31 drop (267 changed files, 4 conflicts); USC 2.2 grafted in; Samus removed in favour of the
  workshop mod (its skill trees had been copied into the `[Eldritch]` files). Endless Legend
  Populations 4.5 merged in (renamed `[ELP]` files, four data fixes) after the workshop item crashed game start. Minor Heroes Reimagined
  [ESG+PST] 0.2 merged in the same way. Samus Aran 1.0 folded back in behind the first ACM New Game toggle
  (`Enable Samus Aran`); Arkon Portal folded in behind a second one, minus its 500-point trait. Arkon Faction Hero Ships
  folded in (always on) — it had been overriding every hero definition from the play set. Endless Moons and Endless
  Anomalies folded in (always on): ESG's anomalies win, Endless Moons' moon mechanics win, weight tables merged.
  Deep Space Mining folded in (strategic lines grafted into ESG's node descriptors). Worthy Deeds folded in behind a third
  toggle, as generated `_WD` copies of ESG's deeds (wonders left as a race). Kaizen Rejuvenation folded in behind a fourth.
