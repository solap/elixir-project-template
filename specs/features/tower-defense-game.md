# Feature: Tower Defense Game

## Feature Description

A real-time tower defense game built with Elixir/Phoenix featuring:
- Single-player gameplay with future multiplayer support architecture
- Game Designer Mode for real-time level creation and testing
- Configurable units/towers via external configuration files
- Tech tree system for tower progression
- Wave-based enemy spawning with customizable patterns
- Multiple damage types and area-of-effect mechanics

The game uses Phoenix LiveView for real-time browser-based gameplay with WebSocket communication, and leverages Elixir's GenServer/process architecture for game state management, making it naturally suited for future multiplayer expansion.

## User Story

As a tower defense player,
I want to strategically place towers along a path to defeat waves of enemies,
So that I can enjoy challenging tactical gameplay and progress through increasingly difficult levels.

As a game designer,
I want to enter a designer mode where I can place towers and spawn enemies in real-time,
So that I can test and balance game mechanics without restarting the game.

## Problem Statement

The user wants a tower defense game that is:
1. Easy to configure and balance through external config files
2. Testable in real-time through a designer mode
3. Architecturally prepared for multiplayer even though single-player is the initial focus
4. Flexible with damage types, AOE effects, and special abilities (like spawning minions)
5. Customizable wave patterns per level

## Solution Statement

Build a Phoenix LiveView-based tower defense game with:

1. **Process-based game engine**: Use GenServers for game state, individual tower processes, and enemy processes - this architecture scales naturally to multiplayer
2. **Configuration-driven design**: YAML/JSON config files for towers, enemies, maps, waves, and tech trees
3. **Designer Mode**: A special game mode accessible via URL parameter or toggle that allows:
   - Dropping any tower regardless of tech tree
   - Spawning enemies manually
   - Adjusting game speed
   - Viewing hitboxes and ranges
   - Real-time stat modifications
4. **Component-based entities**: Towers and enemies share a component system for stats, abilities, and behaviors
5. **Event-driven updates**: PubSub for game events enabling easy multiplayer transition

## Relevant Files

Use these files to implement the feature:

### Existing Files
- **`CLAUDE.md`** - Development conventions and testing patterns to follow
- **`mix.exs.template`** - Reference for adding Phoenix LiveView dependencies
- **`config/*.template`** - Reference for configuration patterns
- **`.claude/context/safety-checklist.md`** - Safety guidelines during implementation

### New Files

#### Core Game Engine
- **`lib/explore/game/engine.ex`** - Main game GenServer managing game state, tick loop, and coordination
- **`lib/explore/game/world.ex`** - Game world state struct (map, towers, enemies, projectiles)
- **`lib/explore/game/tick.ex`** - Game tick processing logic (movement, combat, spawning)

#### Entities
- **`lib/explore/game/entities/tower.ex`** - Tower struct and behavior
- **`lib/explore/game/entities/enemy.ex`** - Enemy struct and behavior
- **`lib/explore/game/entities/projectile.ex`** - Projectile struct for tracking shots
- **`lib/explore/game/entities/minion.ex`** - Spawned minion struct (for bomb towers etc.)

#### Combat System
- **`lib/explore/game/combat/damage.ex`** - Damage types and calculations
- **`lib/explore/game/combat/targeting.ex`** - Target selection strategies (first, closest, strongest, etc.)
- **`lib/explore/game/combat/effects.ex`** - Status effects (slow, burn, poison, etc.)

#### Configuration
- **`lib/explore/game/config/loader.ex`** - YAML/JSON config file loader
- **`lib/explore/game/config/tower_config.ex`** - Tower configuration schema and validation
- **`lib/explore/game/config/enemy_config.ex`** - Enemy configuration schema and validation
- **`lib/explore/game/config/wave_config.ex`** - Wave/level configuration schema
- **`lib/explore/game/config/tech_tree_config.ex`** - Tech tree configuration schema

#### Map System
- **`lib/explore/game/map/path.ex`** - Path definition and waypoint system
- **`lib/explore/game/map/grid.ex`** - Grid-based placement system for towers
- **`lib/explore/game/map/maps/windy_path.ex`** - First map: windy path from left to right

#### Tech Tree
- **`lib/explore/game/tech_tree/tree.ex`** - Tech tree structure and unlocking logic
- **`lib/explore/game/tech_tree/node.ex`** - Individual tech tree node

#### Wave System
- **`lib/explore/game/waves/spawner.ex`** - Enemy wave spawning logic
- **`lib/explore/game/waves/wave.ex`** - Wave definition struct

#### LiveView Interface
- **`lib/explore_web/live/game_live.ex`** - Main game LiveView
- **`lib/explore_web/live/game_live.html.heex`** - Game UI template
- **`lib/explore_web/live/components/game_board.ex`** - Game board component
- **`lib/explore_web/live/components/tower_panel.ex`** - Tower selection panel
- **`lib/explore_web/live/components/wave_info.ex`** - Wave information display
- **`lib/explore_web/live/components/tech_tree_panel.ex`** - Tech tree display
- **`lib/explore_web/live/components/designer_tools.ex`** - Designer mode tools

#### Configuration Files (YAML)
- **`priv/game_config/towers.yml`** - Tower definitions
- **`priv/game_config/enemies.yml`** - Enemy definitions
- **`priv/game_config/maps/windy_path.yml`** - First map definition
- **`priv/game_config/levels/level_01.yml`** - Level 1 wave definitions
- **`priv/game_config/tech_tree.yml`** - Tech tree structure

#### Tests
- **`test/explore/game/engine_test.exs`** - Game engine tests
- **`test/explore/game/combat/damage_test.exs`** - Damage calculation tests
- **`test/explore/game/combat/targeting_test.exs`** - Targeting tests
- **`test/explore/game/config/loader_test.exs`** - Config loading tests
- **`test/explore/game/waves/spawner_test.exs`** - Wave spawning tests
- **`test/explore_web/live/game_live_test.exs`** - LiveView integration tests

## Implementation Plan

### Phase 1: Foundation

1. **Set up Phoenix project with LiveView** - Create the base Phoenix application with LiveView enabled
2. **Design core data structures** - Define structs for World, Tower, Enemy, Projectile with clear typespecs
3. **Create configuration schema** - Design YAML structure for towers, enemies, waves, and maps
4. **Implement config loader** - Parse and validate YAML configuration files
5. **Build basic game engine** - GenServer with game loop tick, state management, and PubSub events

### Phase 2: Core Implementation

1. **Implement map and path system** - Grid placement, path waypoints, movement along paths
2. **Build tower system** - Tower placement, range detection, firing logic
3. **Build enemy system** - Enemy spawning, movement, health, death
4. **Implement damage system** - Multiple damage types, resistances, AOE calculations
5. **Create projectile system** - Projectile movement, hit detection, effects on hit
6. **Build wave spawner** - Wave timing, enemy streaming, wave completion detection

### Phase 3: Integration

1. **Create LiveView game interface** - Real-time rendering with SVG/Canvas
2. **Implement tower placement UI** - Click-to-place with valid location highlighting
3. **Add tech tree UI** - Tech tree display with unlock progression
4. **Build designer mode** - Toggle designer mode, spawn controls, stat viewers
5. **Add game controls** - Start wave, pause, speed controls
6. **Polish and balance** - Test gameplay, adjust configurations

## Step by Step Tasks

### Step 1: Create Phoenix Project Structure

- Run `mix phx.new explore --live` if not already a Phoenix project, or add Phoenix/LiveView deps to existing project
- Add required dependencies to `mix.exs`:
  - `{:yaml_elixir, "~> 2.9"}` for YAML config parsing
  - `{:jason, "~> 1.4"}` for JSON support
- Run `mix deps.get`
- Create directory structure:
  - `lib/explore/game/`
  - `lib/explore/game/entities/`
  - `lib/explore/game/combat/`
  - `lib/explore/game/config/`
  - `lib/explore/game/map/`
  - `lib/explore/game/map/maps/`
  - `lib/explore/game/tech_tree/`
  - `lib/explore/game/waves/`
  - `lib/explore_web/live/`
  - `lib/explore_web/live/components/`
  - `priv/game_config/`
  - `priv/game_config/maps/`
  - `priv/game_config/levels/`

### Step 2: Define Core Data Structures

- Create `lib/explore/game/world.ex`:
  - Define `World` struct with fields: `map`, `towers`, `enemies`, `projectiles`, `tick`, `state`, `resources`
  - Add typespecs for all fields
  - Implement `new/1` function to create initial world state
- Create `lib/explore/game/entities/tower.ex`:
  - Define `Tower` struct: `id`, `type`, `position`, `stats`, `cooldown`, `target`
  - Stats include: `damage`, `damage_type`, `range`, `fire_rate`, `aoe_radius`, `special_abilities`
  - Implement `can_fire?/1`, `fire/2`, `find_target/2` functions
- Create `lib/explore/game/entities/enemy.ex`:
  - Define `Enemy` struct: `id`, `type`, `position`, `health`, `max_health`, `speed`, `path_progress`, `effects`, `resistances`
  - Implement `move/2`, `take_damage/2`, `is_dead?/1`, `apply_effect/2` functions
- Create `lib/explore/game/entities/projectile.ex`:
  - Define `Projectile` struct: `id`, `position`, `target`, `damage`, `damage_type`, `speed`, `aoe_radius`, `effects`
  - Implement `move/1`, `has_hit?/1` functions
- Create `lib/explore/game/entities/minion.ex`:
  - Define `Minion` struct for spawned entities (walking bombs, etc.): `id`, `position`, `damage`, `speed`, `lifetime`
- Write tests in `test/explore/game/entities/` for each entity module

### Step 3: Implement Configuration System

- Create `lib/explore/game/config/loader.ex`:
  - Implement `load/1` to load YAML file from priv directory
  - Implement `load_all/0` to load all game configurations at startup
  - Cache configurations in ETS or application env
  - Add validation for required fields
- Create `lib/explore/game/config/tower_config.ex`:
  - Define tower config schema with all supported attributes
  - Validate damage types: `:physical`, `:fire`, `:ice`, `:lightning`, `:poison`
  - Validate special abilities: `:aoe`, `:slow`, `:spawn_minion`, `:chain_lightning`, etc.
- Create `lib/explore/game/config/enemy_config.ex`:
  - Define enemy config schema
  - Support for resistances per damage type
  - Support for special abilities: `:flying`, `:armored`, `:regenerating`, `:splitting`
- Create `lib/explore/game/config/wave_config.ex`:
  - Define wave schema: list of enemy types, counts, spawn intervals, delays
- Create `lib/explore/game/config/tech_tree_config.ex`:
  - Define tech tree node schema: `id`, `name`, `unlocks`, `requirements`, `cost`
- Create initial config files:
  - `priv/game_config/towers.yml` with at least 5 tower types
  - `priv/game_config/enemies.yml` with at least 5 enemy types
  - `priv/game_config/tech_tree.yml` with initial tech tree
- Write tests in `test/explore/game/config/` for config loading and validation

### Step 4: Build Map and Path System

- Create `lib/explore/game/map/path.ex`:
  - Define `Path` struct with list of waypoints (x, y coordinates)
  - Implement `progress_to_position/2` to convert path progress (0.0-1.0) to world position
  - Implement `distance_along_path/1` to get total path length
  - Implement `interpolate/3` for smooth movement between waypoints
- Create `lib/explore/game/map/grid.ex`:
  - Define `Grid` struct with dimensions and blocked cells
  - Implement `can_place_tower?/2` to check if position is valid
  - Implement `place_tower/3` to mark cell as occupied
  - Implement `get_cell/2` and `set_cell/3` utilities
- Create `lib/explore/game/map/maps/windy_path.ex`:
  - Define the first map with a winding path from left to right
  - Include grid dimensions (e.g., 20x15)
  - Include path waypoints creating S-curve pattern
  - Include valid tower placement zones
- Create `priv/game_config/maps/windy_path.yml`:
  - YAML definition of the windy path map
  - Can be loaded to override or extend hardcoded map
- Write tests for path interpolation and grid placement

### Step 5: Implement Combat System

- Create `lib/explore/game/combat/damage.ex`:
  - Define damage types as atoms: `:physical`, `:fire`, `:ice`, `:lightning`, `:poison`
  - Implement `calculate_damage/3` accounting for resistances
  - Implement `apply_damage/2` to enemy
  - Support for armor piercing, critical hits
- Create `lib/explore/game/combat/targeting.ex`:
  - Implement targeting strategies as modules/functions:
    - `:first` - Enemy furthest along path
    - `:last` - Enemy closest to spawn
    - `:closest` - Enemy nearest to tower
    - `:strongest` - Enemy with highest health
    - `:weakest` - Enemy with lowest health
  - Implement `find_target/3` that takes tower, enemies, strategy
  - Implement `enemies_in_range/3` utility
- Create `lib/explore/game/combat/effects.ex`:
  - Define effect structs: `Slow`, `Burn`, `Poison`, `Freeze`, `Stun`
  - Each effect has: `duration`, `strength`, `tick_damage` (if applicable)
  - Implement `apply_effect/2`, `tick_effects/1`, `remove_expired/1`
- Write comprehensive tests for damage calculations and targeting

### Step 6: Build Game Engine

- Create `lib/explore/game/engine.ex`:
  - GenServer managing game state
  - State includes: `world`, `config`, `game_speed`, `paused`, `designer_mode`
  - Implement `init/1` to load configs and create initial world
  - Implement `handle_info(:tick, state)` for game loop (default 60 ticks/sec)
  - Expose public API:
    - `start_game/1` - Start new game with map/level
    - `place_tower/3` - Place tower at position
    - `start_wave/1` - Begin next wave
    - `pause/1`, `resume/1` - Pause controls
    - `set_speed/2` - Adjust game speed
    - `get_state/1` - Get current world state for rendering
- Create `lib/explore/game/tick.ex`:
  - Implement `process_tick/1` taking world, returning updated world
  - Steps per tick:
    1. Spawn enemies if wave active
    2. Move enemies along path
    3. Update tower cooldowns
    4. Towers acquire targets and fire
    5. Move projectiles
    6. Process projectile hits
    7. Apply damage and effects
    8. Remove dead enemies
    9. Check win/lose conditions
- Set up PubSub for game events: `:enemy_spawned`, `:tower_fired`, `:enemy_killed`, `:wave_complete`, `:game_over`
- Write tests for engine state management and tick processing

### Step 7: Implement Wave System

- Create `lib/explore/game/waves/wave.ex`:
  - Define `Wave` struct: `number`, `enemy_groups`, `state` (`:waiting`, `:spawning`, `:complete`)
  - Enemy group: `{enemy_type, count, interval_ms}`
- Create `lib/explore/game/waves/spawner.ex`:
  - GenServer or module for wave spawning logic
  - Implement `start_wave/2` taking wave config
  - Track spawn timing and remaining enemies
  - Emit `:enemy_spawned` events via PubSub
  - Implement `is_wave_complete?/1`
- Create `priv/game_config/levels/level_01.yml`:
  - Define 10 waves with increasing difficulty
  - Mix of enemy types
  - Configurable spawn intervals and delays between waves
- Write tests for wave spawning timing and completion

### Step 8: Implement Tech Tree System

- Create `lib/explore/game/tech_tree/node.ex`:
  - Define `Node` struct: `id`, `name`, `description`, `unlocks` (tower types), `requirements` (other nodes), `cost`
  - Implement `is_unlocked?/2`, `can_unlock?/2`
- Create `lib/explore/game/tech_tree/tree.ex`:
  - Define `Tree` struct with nodes and unlocked set
  - Load tree structure from config
  - Implement `unlock_node/2` to unlock a node if requirements met
  - Implement `available_towers/1` to get currently unlocked towers
  - Implement `available_to_unlock/1` to get nodes that can be unlocked
- Update game engine to track tech tree state
- For designer mode: bypass tech tree restrictions
- Write tests for unlock logic and requirements checking

### Step 9: Create LiveView Game Interface

- Create `lib/explore_web/live/game_live.ex`:
  - Mount handler: start game engine, subscribe to PubSub
  - Handle params for designer mode (`?designer=true`)
  - Track: `engine_pid`, `world`, `selected_tower`, `designer_mode`, `ui_state`
  - Handle events:
    - `"place_tower"` - Place selected tower at click position
    - `"select_tower"` - Select tower type from panel
    - `"start_wave"` - Begin next wave
    - `"toggle_pause"` - Pause/resume
    - `"set_speed"` - Change game speed
  - Receive PubSub messages to trigger re-render
- Create `lib/explore_web/live/game_live.html.heex`:
  - SVG-based game board (scalable, crisp rendering)
  - Tower panel on right side
  - Wave info at top
  - Resources/score display
  - Designer tools panel (conditional)
- Add route in `router.ex`: `live "/game", GameLive`
- Write integration tests for LiveView

### Step 10: Build Game Board Component

- Create `lib/explore_web/live/components/game_board.ex`:
  - Functional component receiving `world` assign
  - Render SVG with viewBox for proper scaling
  - Render layers:
    1. Background/terrain
    2. Path (visualized for player)
    3. Tower placement grid (highlighted valid spots)
    4. Towers (with range indicators on hover/select)
    5. Enemies (with health bars)
    6. Projectiles
    7. Effects (explosions, etc.)
  - Handle click events for tower placement
  - Show tower range on hover
- Implement smooth animations using CSS transitions or requestAnimationFrame via hooks
- Add visual feedback for valid/invalid placement

### Step 11: Build UI Panels

- Create `lib/explore_web/live/components/tower_panel.ex`:
  - Display available towers (filtered by tech tree in normal mode)
  - Show tower stats on hover
  - Highlight selected tower
  - Show tower cost
  - Disable towers player can't afford
- Create `lib/explore_web/live/components/wave_info.ex`:
  - Display current wave number
  - Show enemies remaining
  - Preview next wave composition
  - "Start Wave" button
- Create `lib/explore_web/live/components/tech_tree_panel.ex`:
  - Visual tech tree with nodes
  - Show locked/unlocked state
  - Show requirements for locked nodes
  - Allow unlocking if requirements met

### Step 12: Implement Designer Mode

- Create `lib/explore_web/live/components/designer_tools.ex`:
  - Only rendered when `designer_mode` is true
  - Features:
    - Toggle to show all towers (bypass tech tree)
    - Spawn enemy dropdown/buttons
    - Game speed slider (0.25x to 4x)
    - Pause/step controls
    - Toggle hitbox/range visualization
    - Current tick display
    - Entity inspector (click enemy/tower to see stats)
    - Resource override input
- Add hotkeys for designer tools (via LiveView hooks):
  - `P` - Pause/resume
  - `+/-` - Speed up/slow down
  - `Space` - Single step when paused
  - `D` - Toggle debug visualization
- Update game engine to expose designer controls

### Step 13: Create Tower Configuration

- Update `priv/game_config/towers.yml` with complete tower definitions:
```yaml
towers:
  arrow_tower:
    name: "Arrow Tower"
    cost: 100
    stats:
      damage: 10
      damage_type: physical
      range: 150
      fire_rate: 1.0  # shots per second
      projectile_speed: 400
    targeting: first

  flame_tower:
    name: "Flame Tower"
    cost: 200
    stats:
      damage: 5
      damage_type: fire
      range: 100
      fire_rate: 2.0
      aoe_radius: 50
    effects:
      - type: burn
        duration: 3000
        damage_per_tick: 2
    targeting: closest

  frost_tower:
    name: "Frost Tower"
    cost: 250
    stats:
      damage: 8
      damage_type: ice
      range: 120
      fire_rate: 0.8
    effects:
      - type: slow
        duration: 2000
        strength: 0.5
    targeting: first

  lightning_tower:
    name: "Lightning Tower"
    cost: 350
    stats:
      damage: 25
      damage_type: lightning
      range: 140
      fire_rate: 0.5
      chain_targets: 3
      chain_damage_falloff: 0.7
    targeting: strongest

  bomb_launcher:
    name: "Bomb Launcher"
    cost: 300
    stats:
      damage: 40
      damage_type: physical
      range: 180
      fire_rate: 0.3
      aoe_radius: 80
    targeting: first

  minion_factory:
    name: "Minion Factory"
    cost: 400
    stats:
      damage: 0
      range: 0
      spawn_interval: 5.0  # seconds
    special:
      spawn_minion:
        type: walking_bomb
        damage: 30
        speed: 50
        lifetime: 10000
```

### Step 14: Create Enemy Configuration

- Update `priv/game_config/enemies.yml`:
```yaml
enemies:
  grunt:
    name: "Grunt"
    health: 100
    speed: 50
    reward: 10
    resistances: {}

  runner:
    name: "Runner"
    health: 50
    speed: 100
    reward: 15
    resistances: {}

  tank:
    name: "Tank"
    health: 500
    speed: 30
    reward: 50
    resistances:
      physical: 0.3

  fire_elemental:
    name: "Fire Elemental"
    health: 150
    speed: 60
    reward: 25
    resistances:
      fire: 0.8
    weaknesses:
      ice: 0.5

  ice_golem:
    name: "Ice Golem"
    health: 300
    speed: 40
    reward: 40
    resistances:
      ice: 0.9
    weaknesses:
      fire: 0.5
      lightning: 0.3

  swarm:
    name: "Swarm"
    health: 30
    speed: 70
    reward: 5
    special:
      split_on_death:
        count: 2
        type: mini_swarm

  mini_swarm:
    name: "Mini Swarm"
    health: 15
    speed: 80
    reward: 2

  boss_ogre:
    name: "Ogre Boss"
    health: 2000
    speed: 25
    reward: 200
    resistances:
      physical: 0.2
      fire: 0.2
      ice: 0.2
    special:
      regenerate:
        amount: 5
        interval: 1000
```

### Step 15: Create Level Configuration

- Create `priv/game_config/levels/level_01.yml`:
```yaml
level:
  name: "The Winding Path"
  map: windy_path
  starting_resources: 500
  starting_lives: 20
  waves:
    - number: 1
      enemies:
        - type: grunt
          count: 10
          interval: 1000
      delay_after: 5000

    - number: 2
      enemies:
        - type: grunt
          count: 8
          interval: 800
        - type: runner
          count: 5
          interval: 600
      delay_after: 5000

    - number: 3
      enemies:
        - type: grunt
          count: 12
          interval: 700
        - type: tank
          count: 2
          interval: 3000
      delay_after: 7000

    # Continue for 10 waves...

    - number: 10
      enemies:
        - type: tank
          count: 5
          interval: 2000
        - type: fire_elemental
          count: 8
          interval: 1000
        - type: runner
          count: 15
          interval: 500
        - type: boss_ogre
          count: 1
          interval: 0
      delay_after: 0
```

### Step 16: Create Tech Tree Configuration

- Create `priv/game_config/tech_tree.yml`:
```yaml
tech_tree:
  nodes:
    basic_towers:
      name: "Basic Towers"
      description: "Unlock basic tower types"
      unlocks: [arrow_tower]
      requirements: []
      cost: 0  # Unlocked by default

    fire_mastery:
      name: "Fire Mastery"
      description: "Harness the power of fire"
      unlocks: [flame_tower]
      requirements: [basic_towers]
      cost: 100

    frost_mastery:
      name: "Frost Mastery"
      description: "Control ice and cold"
      unlocks: [frost_tower]
      requirements: [basic_towers]
      cost: 100

    storm_mastery:
      name: "Storm Mastery"
      description: "Command lightning"
      unlocks: [lightning_tower]
      requirements: [fire_mastery, frost_mastery]
      cost: 250

    explosives:
      name: "Explosives"
      description: "Explosive ordinance"
      unlocks: [bomb_launcher]
      requirements: [basic_towers]
      cost: 150

    minion_tech:
      name: "Minion Technology"
      description: "Create autonomous fighters"
      unlocks: [minion_factory]
      requirements: [explosives, storm_mastery]
      cost: 400

  starting_unlocked: [basic_towers]
```

### Step 17: Integration Testing

- Create comprehensive integration tests:
  - Test full game loop: start game, place towers, run waves, win/lose
  - Test designer mode functionality
  - Test config loading and validation
  - Test LiveView interactions
- Load testing for performance with many enemies
- Test edge cases:
  - Selling towers
  - Upgrading towers (if implemented)
  - Pause during wave
  - Multiple projectiles in flight

### Step 18: Polish and Validation

- Run `mix format`
- Run `mix compile --warnings-as-errors`
- Run `mix credo --min-priority high`
- Run `mix test`
- Play-test the game in designer mode
- Balance tower costs and damage values
- Verify all config files load correctly

## Testing Strategy

### Unit Tests

- **Entity tests** (`test/explore/game/entities/`)
  - Tower targeting and firing logic
  - Enemy movement and damage calculations
  - Projectile movement and hit detection
  - Minion spawning and behavior

- **Combat tests** (`test/explore/game/combat/`)
  - Damage calculations with resistances
  - AOE damage distribution
  - Effect application and duration
  - Targeting strategy correctness

- **Config tests** (`test/explore/game/config/`)
  - Valid config parsing
  - Invalid config rejection with helpful errors
  - Default value handling
  - Schema validation

### Integration Tests

- **Game engine tests** (`test/explore/game/engine_test.exs`)
  - Full game lifecycle
  - State transitions (waiting, playing, paused, won, lost)
  - PubSub event emission
  - Multiple simultaneous games (process isolation)

- **LiveView tests** (`test/explore_web/live/game_live_test.exs`)
  - Page load and initial render
  - Tower placement interaction
  - Wave start interaction
  - Designer mode toggle
  - Real-time updates

### Edge Cases

- Enemy reaches end of path (life lost)
- All lives lost (game over)
- All waves complete (victory)
- Tower placed on invalid location
- Tower placed when insufficient resources
- Wave started while previous incomplete
- Projectile target dies before hit
- Effect applied to already-affected enemy
- Tech tree unlock with insufficient points
- Designer mode resource manipulation
- Pause/resume state preservation
- Very high game speed (4x) stability

## Acceptance Criteria

1. **Game loads and displays correctly**
   - LiveView renders at `/game`
   - Map with winding path is visible
   - Tower panel shows available towers
   - Wave info displays correctly

2. **Core gameplay works**
   - Towers can be placed on valid grid positions
   - Towers fire at enemies in range
   - Enemies move along path and take damage
   - Enemies die when health reaches zero
   - Lives are lost when enemies reach the end
   - Game ends on victory or defeat

3. **Configuration system works**
   - All configs load from YAML files
   - Tower stats match config values
   - Enemy stats match config values
   - Wave spawning matches config

4. **Designer mode works**
   - Accessible via `?designer=true` URL parameter
   - All towers available regardless of tech tree
   - Can spawn enemies manually
   - Can adjust game speed
   - Can view entity stats

5. **Tech tree functions**
   - Only unlocked towers available in normal mode
   - Can unlock nodes when requirements met
   - Unlocking grants access to new towers

6. **All quality checks pass**
   - `mix format` produces no changes
   - `mix compile --warnings-as-errors` succeeds
   - `mix credo --min-priority high` passes
   - `mix test` all tests pass

## Validation Commands

Execute every command to validate the feature works correctly with zero regressions.

```bash
# Format code
mix format

# Compile with strict warnings
mix compile --all-warnings --warnings-as-errors

# Run static analysis
mix credo --min-priority high

# Run all tests
mix test

# Run tests with coverage
mix test --cover

# Start the server and manually test
mix phx.server
# Then navigate to http://localhost:4000/game
# And http://localhost:4000/game?designer=true

# Validate configs load correctly (add a mix task for this)
mix run -e "Explore.Game.Config.Loader.load_all() |> IO.inspect()"
```

## Notes

### Additional Things to Consider (Answering User's Question)

1. **Resource Economy**
   - Earning resources from killing enemies
   - Resource income over time?
   - Tower selling (refund percentage?)
   - Tower upgrades (paths or linear?)

2. **Visual/Audio Feedback**
   - Hit effects (damage numbers?)
   - Death animations
   - Tower attack animations
   - Sound effects (consider Phoenix hooks for Web Audio API)

3. **Persistence**
   - Save/load game state
   - Player progress (tech tree unlocks across sessions)
   - High scores / leaderboards

4. **Advanced Tower Mechanics**
   - Tower upgrades (3 paths like BTD?)
   - Tower selling
   - Tower synergies (adjacent tower bonuses)

5. **Advanced Enemy Mechanics**
   - Boss special abilities (immunity phases, spawning adds)
   - Flying enemies (different path or no path?)
   - Invisible enemies (require detection towers)
   - Healing enemies

6. **Map Features**
   - Multiple entry/exit points
   - Branching paths
   - Environmental hazards
   - Buildable terrain vs. unbuildable

7. **Multiplayer Preparation**
   - Competitive mode (send enemies to opponent)
   - Cooperative mode (shared map)
   - Lobby system
   - Matchmaking

8. **Balancing Tools**
   - Simulation mode (run 1000 games with strategy X)
   - Statistics collection
   - A/B testing configs

9. **Performance Considerations**
   - Maximum enemies on screen
   - Projectile pooling
   - Spatial partitioning for range queries
   - Client-side prediction for smooth movement

10. **Accessibility**
    - Colorblind modes
    - Keyboard controls
    - Screen reader support for key info
    - Adjustable difficulty

### Architecture Decisions

- **Why GenServer per game, not per entity?**: Simpler to reason about, avoids message-passing overhead for tight game loops. Can spawn entity processes if needed for multiplayer.
- **Why YAML over database?**: Game config is static per deployment, YAML is human-readable and version-controllable. Easy for designers to modify.
- **Why SVG over Canvas?**: SVG is declarative and integrates naturally with LiveView. Canvas requires JavaScript hooks but offers better performance for many entities.
- **Why not use an existing game framework?**: Learning exercise, full control, Elixir-native patterns.

### Future Multiplayer Architecture

The current architecture is designed to enable multiplayer:

1. **Game engine as GenServer** - Easy to run multiple instances
2. **PubSub for events** - Can be distributed via Phoenix.PubSub
3. **State as immutable structs** - Can be serialized for network sync
4. **Configuration-driven** - Same configs across clients
5. **Designer mode** - Can become admin/spectator mode

Multiplayer additions would include:
- Phoenix Channels for real-time sync
- Presence for player tracking
- Game lobby GenServer
- State reconciliation logic
- Anti-cheat (server-authoritative)
