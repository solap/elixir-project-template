# Feature: Designer Mode Toggle, Enhanced Visuals, and Creature Variety

## Feature Description
This feature enhances the tower defense game with three major improvements:
1. **Designer Mode Toggle** - A button in the UI to toggle designer mode on/off without URL parameters, with unlimited resources in designer mode
2. **Unique Tower Visuals** - Each tower type gets a distinctive SVG graphic and unique projectile style
3. **Damage Type Explosions** - Different explosion animations for each damage type (physical, fire, ice, lightning, poison, energy)
4. **Creature Variety** - New enemy types with different sizes, speeds, appearances, and animations; levels limited to 2 creature types each

## User Story
As a game designer/player
I want to toggle designer mode, see visually distinct towers and creatures, and experience varied wave compositions
So that I can test the game easily and have a more engaging visual experience

## Problem Statement
Currently:
- Designer mode requires URL parameter (`?designer=true`), making it inconvenient to toggle
- All towers look identical (blue square with turret)
- All projectiles look the same (yellow circle)
- Explosions are uniform regardless of damage type
- Enemy variety exists but all enemies look the same (red circle with eyes)
- Some waves have more than 2 enemy types, reducing visual clarity

## Solution Statement
1. Add a "Designer Mode" toggle button in the top bar that enables/disables designer mode dynamically, and sets resources to 99999 when enabled
2. Create unique SVG graphics for each tower type (arrow, flame, frost, lightning, bomb, minion factory, sniper, poison, laser, cannon)
3. Create unique projectile visuals per tower (arrows, fireballs, ice shards, lightning bolts, bombs, bullets, poison globs, laser beams)
4. Create damage-type-specific explosion animations (physical=grey shockwave, fire=orange flame burst, ice=blue frost shatter, lightning=yellow electric crackle, poison=green toxic cloud, energy=purple pulse)
5. Add visual configs to enemies.yml defining size, color, shape, and animation style for each enemy type
6. Update level_01.yml to limit each wave to exactly 2 enemy types

## Relevant Files
Use these files to implement the feature:

- `lib/explore_web/live/game_live.ex` - Add designer mode toggle button and event handler
- `lib/explore/game/engine.ex` - Modify set_designer_mode to also set resources to 99999
- `lib/explore_web/live/components/game_components.ex` - Add unique tower/enemy/projectile/explosion SVG components
- `assets/css/app.css` - Add animations for different enemy types and explosion effects
- `priv/game_config/towers.yml` - Add visual config (color, shape, projectile_type) to each tower
- `priv/game_config/enemies.yml` - Add visual config (size, color, shape, animation) to each enemy
- `priv/game_config/levels/level_01.yml` - Reduce each wave to max 2 enemy types
- `lib/explore/game/combat/damage.ex` - Already has damage_type_color, may need explosion config

### New Files
- None required - all changes extend existing files

## Implementation Plan
### Phase 1: Foundation
- Add designer mode toggle button to UI
- Update engine to set resources to 99999 when designer mode is enabled
- Add visual configuration schema to towers.yml and enemies.yml

### Phase 2: Core Implementation
- Create unique tower SVG components (one per tower type)
- Create unique projectile SVG components (one per projectile type)
- Create explosion animation components for each damage type
- Create unique enemy SVG components with size/color/animation variations

### Phase 3: Integration
- Wire up visual configs from YAML to components
- Update level_01.yml waves to use max 2 enemy types
- Add CSS animations for new visual effects
- Test all visual combinations

## Step by Step Tasks

### Step 1: Add Designer Mode Toggle Button
- Add a toggle button in `game_live.ex` render function in the top bar
- Add `handle_event("toggle_designer_mode", ...)` that calls `Engine.set_designer_mode/2`
- Update `Engine.set_designer_mode/2` in `engine.ex` to set resources to 99999 when enabling designer mode
- Button should show current state (ON/OFF) and change color accordingly

### Step 2: Add Visual Config to towers.yml
- Add `visual` section to each tower with:
  - `color`: primary color
  - `shape`: base shape (square, circle, hexagon, etc.)
  - `projectile_type`: arrow, fireball, iceball, lightning, bomb, bullet, poison_glob, laser_beam
- Example structure for each tower type

### Step 3: Add Visual Config to enemies.yml
- Add `visual` section to each enemy with:
  - `size`: small (r=4), medium (r=6), large (r=10), boss (r=16)
  - `color`: primary body color
  - `accent_color`: secondary/detail color
  - `shape`: circle, square, triangle, blob
  - `animation`: bounce, wobble, pulse, crawl, float
- Update existing enemies with appropriate visuals

### Step 4: Create Tower Visual Components
- In `game_components.ex`, create `tower_visual/1` function component
- Pass tower type and render unique SVG based on type:
  - `arrow_tower`: wooden frame with bow
  - `flame_tower`: brazier with flames
  - `frost_tower`: ice crystal
  - `lightning_tower`: tesla coil
  - `bomb_launcher`: mortar/catapult
  - `minion_factory`: small factory building
  - `sniper_tower`: tall narrow tower with scope
  - `poison_tower`: bubbling cauldron
  - `laser_tower`: futuristic dish
  - `cannon_tower`: classic cannon

### Step 5: Create Projectile Visual Components
- In `game_components.ex`, update `projectile/1` to render based on `damage_type` or `projectile_type`:
  - `arrow`: elongated triangle pointing in direction of travel
  - `fireball`: orange/red circle with flame trail
  - `iceball`: blue hexagon with sparkle
  - `lightning`: jagged line (polyline)
  - `bomb`: black circle with lit fuse
  - `bullet`: small fast grey circle
  - `poison_glob`: green dripping blob
  - `laser_beam`: line with glow (using filter)

### Step 6: Create Explosion Visual Components
- In `game_components.ex`, update `effect/1` to render based on damage type:
  - `physical`: grey expanding ring that fades
  - `fire`: orange/red burst with particles
  - `ice`: blue crystalline shatter pattern
  - `lightning`: yellow electric arcs
  - `poison`: green toxic cloud that lingers
  - `energy`: purple pulsing wave
- Add corresponding CSS animations in `app.css`

### Step 7: Create Enemy Visual Components
- In `game_components.ex`, update `enemy/1` to read visual config and render:
  - Different sizes based on `size` config
  - Different shapes (circle, square with rounded corners, triangle, blob path)
  - Different colors from config
  - Apply animation class based on `animation` config
- Add CSS animations for each animation type

### Step 8: Update Level Configuration
- In `level_01.yml`, modify each wave to have at most 2 enemy types
- Ensure good variety across waves (different pairs each wave)
- Maintain game balance with adjusted counts/intervals

### Step 9: Add CSS Animations
- Add in `app.css`:
  - `.enemy-bounce` - vertical bounce
  - `.enemy-wobble` - side-to-side rotation
  - `.enemy-pulse` - scale pulse
  - `.enemy-crawl` - slow undulating movement
  - `.enemy-float` - gentle floating motion
  - `.explosion-physical`, `.explosion-fire`, `.explosion-ice`, `.explosion-lightning`, `.explosion-poison`, `.explosion-energy`

### Step 10: Wire Up Visual Configs
- Update `game_components.ex` to receive and use config from game_state
- Pass enemy visual config through to enemy component
- Pass tower visual config through to tower component
- Ensure projectile type is passed from tower config

### Step 11: Validation and Testing
- Run `mix format`
- Run `mix compile --warnings-as-errors`
- Run `mix test`
- Manual testing: verify designer mode toggle works
- Manual testing: verify each tower has unique appearance
- Manual testing: verify each enemy type looks different
- Manual testing: verify explosions vary by damage type

## Testing Strategy
Focus more on Integration Tests

### Unit Tests
- Test that `Engine.set_designer_mode/2` sets resources to 99999 when enabling
- Test that visual configs are properly loaded from YAML

### Integration Tests
- Test LiveView `toggle_designer_mode` event handler
- Test that designer mode enables/disables correctly via button
- Test that game_state includes visual configs

### Edge Cases
- Toggling designer mode mid-wave
- Missing visual config falls back to defaults
- Invalid animation type falls back to default

## Acceptance Criteria
- [ ] Designer mode toggle button visible in UI
- [ ] Clicking toggle button enables/disables designer mode
- [ ] Enabling designer mode sets resources to 99999
- [ ] All towers unlocked in designer mode
- [ ] Each tower type has visually distinct appearance
- [ ] Each projectile type looks different
- [ ] Explosions vary based on damage type
- [ ] Each enemy type has unique size, color, and animation
- [ ] No wave has more than 2 enemy types
- [ ] All tests pass
- [ ] No compilation warnings

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

```bash
# Format code
mix format

# Compile without warnings
mix compile --warnings-as-errors

# Run all tests
mix test

# Start server for manual testing
mix phx.server
```

Manual validation checklist:
1. Open http://localhost:4000/game
2. Click "Designer Mode" toggle - verify it turns ON and resources become 99999
3. Verify all tower types appear in panel
4. Place each tower type - verify unique visuals
5. Start wave - verify enemies have different appearances
6. Watch projectiles - verify they look different per tower
7. Watch explosions - verify different damage types have different effects
8. Click "Designer Mode" toggle again - verify it turns OFF
9. Verify tech tree restrictions apply when designer mode is off

## Notes
- Keep visual complexity reasonable for performance (avoid too many SVG elements per entity)
- Use CSS animations where possible instead of JS for better performance
- Explosion effects should be short-lived (< 500ms) to avoid cluttering the screen
- Consider adding a small info tooltip showing enemy type on hover (future enhancement)
- The laser_tower could use a beam effect rather than projectile (future enhancement)
- Boss enemies should have more elaborate visuals than regular enemies
