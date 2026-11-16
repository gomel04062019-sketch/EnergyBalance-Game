# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Энергобаланс города" — an isometric city-builder/economy educational game in **GameMaker (GML)**, project file `Path_1.yyp` (IDE v2026.0.0.16, runtime v2026.0.0.23). README and in-game text are in Russian; keep new UI strings/comments consistent with that.

There is no CLI build, lint, or test setup. Open `Path_1.yyp` in the GameMaker IDE and run with F5 (start room is `rm_menu`; `Room1` is the game). Resources are edited both in the IDE and as plain text (`.gml` / `.yy` files) — avoid hand-editing `.yy` files unless necessary, as the IDE rewrites them. Use Git Bash-style single-line commands.

## Architecture

All game logic lives in **`obj_controller`** (placed in `Room1`); there is no `scripts/` folder. Other objects are mostly data holders.

- `obj_controller/Create_0.gml` — initializes all state as `global.*` (money, eco_score, weather, day/night, quest stage, tech upgrades, menu flags, tips) and procedurally generates the map: three layers of staggered isometric tiles (`obj_water` depth 1001, `obj_sand` 1000, `obj_grass` 999; tile 64×16, odd rows offset by half a tile). The buildable area is `global.grass_x1/y1/x2/y2`.
- `obj_controller/Step_0.gml` — single per-frame pipeline, in order: pause/F11/`T` toggles (early `exit` when paused, not playing, or a menu is open) → quest state machine (`global.quest_stage` 1–5, win sets `global.game_state = "win"`) → build/demolish input → weather/day-night (every 300 steps) and energy totals → money/eco update → camera (WASD/arrows) → tips timer. Early `exit`s mean anything placed after them stops while menus/pause are active.
- `obj_controller/Draw_64.gml` — the entire GUI (HUD, build panel, build menu, tech tree, quest journal, win screen) drawn in GUI space. Click hit-testing for the build panel/menu is done **in Step_0 with hard-coded pixel layout that must match the geometry in Draw_64** (e.g. `ui_y = gui_height - 150`, `btn_w = 160`, menu 700×260, cells 210×210). Change both together.
- `obj_ghost` — placement preview. Created by the controller on click with `sprite_index`, `spawn_obj`, `cost` set per `build_mode`; its Step snaps to a 64×32 grid, checks bounds against the grass rectangle, `place_meeting(obj_building)`, and money, then tints green/red and sets `can_build`. The controller spawns `spawn_obj` and deducts cost when clicked.
- Building hierarchy (via `parentObjectId` in `.yy`): `obj_building` → `obj_residential` → `obj_house` / `obj_medium_house` / `obj_lux_house` (use `energy_use`, `money_gain`); `obj_building` → `obj_tec` / `obj_solar` / `obj_wind` (use `energy_gen`, `pollution`). Energy/income loops in Step_0 use `with (obj_tec)`, `with (obj_residential)` etc., so new building types should inherit from the right parent to be counted.
- `obj_menu` / `rm_menu` — main menu (arrow keys + Enter; only "start" and "exit" are implemented).

### Adding a building type
Requires touching several places: new object + sprite with correct parent, a `build_mode` case in the ghost-creation `switch` in Step_0 (sprite, `spawn_obj`, `cost`), a click-hit case in the build-menu section of Step_0, the matching cell drawn in Draw_64, and (for generators) a clause in the energy section of Step_0. Note the ghost's cost is set in Step_0's `switch`, separate from the `cost` in the object's own Create event — keep them in sync (demolish refunds `cost / 2`).

## Game rules worth knowing
- Energy: TЭЦ (`obj_tec`) constant; wind ×2 when `weather == "windy"`; solar 0 at night, half when cloudy. Residential income is only paid when `total_energy >= used_energy`. The insulation upgrade halves consumption; the filter upgrade halves pollution.
- Eco drops by `total_pollution / 4000` per step, recovers by 0.01 when no pollution; eco < 50 drains money.
- Docs: `docs/index.md`, `docs/report.md` (project report), README (Russian setup instructions).
