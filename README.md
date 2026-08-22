# Amradyr Collective Mods (ACM) for Endless Space 2

A personal modpack that merges mods which are incompatible by default — they redefine the same
definitions, and ES2 resolves duplicates by load order (last loaded wins each definition wholesale,
no merging). So the merged definitions have to be authored somewhere; this repo is that somewhere.

Merged in (credit to the original authors — I resolve conflicts and fix bugs):

- **ESG Mod 1.6** (Endless Space Gaming) — the base. Workshop 2828917317, drop of 2026-05-31.
- **Useful Skill Colours [ESG] 2.2** (mdel) — workshop 3384708155, 2026-07-26.
- **More Traits** (Redraluin) — workshop 932777803, incl. fixes.
- **Political Skill Trees** (workshop 2856109167).
- Own content: the Eldritch faction trait category (`*[Eldritch].xml`).

Carried as separate, toggleable addon modules under `Addons/` (see below):

- **Endless Legend Populations 4.5** (Captain Cobbs) — workshop 1816492263, 2024-11-26, as `ACM-ELP`.

## Play set

Enable ACM plus these workshop mods. Mods not listed here (More Traits, Political Skill Trees,
Useful Skill Colours, the quest example) are already inside ACM or unwanted — leave them disabled.

| Mod | Workshop id | Overlap with ACM (`tools/Find-Conflicts.ps1`) | Notes |
|---|---|---|---|
| Samus Aran | 3268328942 | `AffinityMappingTerrans` only | **Required**: ACM's `FactionTraitEldritchHero` recruits `Samus`. Load **before** ACM so ACM's Terran affinity (with ESG's mercenary ship designs) wins; Samus then comes via the Eldritch trait, not automatically to Terrans. If it loads after ACM, Terrans get her but lose the 8 mercenary designs. |
| Arkon Portal | 1788325573 | none | clean extension |
| Endless Legend Populations | 1816492263 | 27 `FactionTrait` + `ClassColonizedStarSystem` | **Do not use the workshop item** — its `ClassColonizedStarSystem` replaces ESG's and the game crashes on the first colonisation (`ColonizationThresholdFIDSBonus` missing). Use the `ACM-ELP` addon instead. |
| Endless Moons | 1316786885 | 90 (75 descriptors, 6 anomaly reductions, 3 weight tables, 2 anomalies, 2 improvements) | |
| Endless Anomalies | 3257341334 | 126 (51 `AnomalyDefinition`, 73 descriptors, 2 weight tables) | its own note: load **after** Endless Moons |
| Arkon Faction Hero Ships [ESG] | 3175229111 | all 97 `HeroDefinition`s | built on ESG 1.5 hero defs; loading it after ACM replaces ESG 1.6's hero definitions with Arkon's versions |

Overlap counts are the definitions the later-loaded mod will override. Re-run the checker after any
upstream refresh; the full report with names is one command away.

## Addons (optional modules)

Some mods cannot be merged into ACM's files (nothing in ES2's data format lets a game-setting
switch a minor faction or faction trait off), but also cannot run alongside ACM unpatched. Those
live in `Addons/<name>/` as complete RuntimeModules with their own index XML, patched to coexist
with ACM, and each has a vendor branch like the merged mods. ES2 only sees mods directly under
`Community\`, so run `.	ools\Install-Addons.ps1` once — it junctions `Community\<name>` to
`Addons\<name>` — and toggle them in the Mods menu.

| Addon | Source | What ACM changed |
|---|---|---|
| `ACM-ELP` — Endless Legend Populations | workshop 1816492263 (4.5) | dropped its `SimulationDescriptors[ColonizedStarSystem].xml` (ESG 1.6 already carries the one property it added, `OnGoingLords`); dropped its copies of the 27 vanilla starting-minor-pop traits (ESG's apply, and ESG lets them stack, so ELP's own traits follow the same rule); fixed Mykara tier 2 (pathed to Morgawr pops), Morgawr tier 1 (pushed politics via the Necrophage descriptor), Wild Walkers boosted-pop `$(PlanetIsTeemings)` typo, Morgawr fertile influence written as a non-binary modifier. Added English fallbacks for brazilian/polish. Load after ACM. |

## Working on the mod

- This folder is the git working tree **and** the folder ES2 loads (`Documents\Endless Space 2\Community`).
  The `.git` file points at the object store in `C:\Users\Kenny\source\repos\ES2-ACM.git`; edit → save →
  launch the game, no copy step.
- Refreshing an upstream mod: `.\tools\Import-Upstream.ps1 -Mod esg` (or `usc`), then
  `git merge upstream/esg`. Details, conflict conventions and gotchas are in `CLAUDE.md`.
- `.\tools\Find-Conflicts.ps1 -Mod <workshop id>` reports which definitions a workshop mod shares with ACM.

## History

- 2025-02: ESG 1.6 import; More Traits, Political Skill Trees, Useful Skill Colours integrated; Eldritch + Samus added.
- 2026-08: repo relocated into the Community folder; vendor branches + import tooling; ESG refreshed to the
  2026-05-31 drop (267 changed files, 4 conflicts); USC 2.2 grafted in; Samus removed in favour of the
  workshop mod (its skill trees had been copied into the `[Eldritch]` files). Endless Legend
  Populations brought in as the patched `ACM-ELP` addon after the workshop item crashed game start.
