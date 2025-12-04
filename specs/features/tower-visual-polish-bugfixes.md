# Feature: Tower Visual Polish and Bug Fixes

## Feature Description
A comprehensive update to fix critical bugs and improve the visual polish of the tower defense game. This includes fixing game-breaking bugs (freeze tower hang, designer mode issues), improving tower projectile visuals to match their type, adding proper animations for effects and minions, and implementing smart targeting for the poison tower.

## User Story
As a player
I want towers to have distinct, polished visuals and effects that work correctly
So that I can enjoy a bug-free, visually appealing tower defense game

## Problem Statement
Multiple issues affect gameplay and visual quality:

### Critical Bugs:
1. **Freeze tower causes game hang** - When frost tower hits one enemy, all enemies freeze and the game stops
2. **Designer mode doesn't bypass tower selection cost check** - Can't select towers in designer mode if insufficient funds
3. **Designer mode button is confusing** - "Designer: ON/OFF" unclear if it shows current state or action

### Visual Issues:
1. **Walking bomb animation** - Needs better bomb visual
2. **Sniper tower fires arrows** - Should fire bullets instead
3. **Cannon tower fires arrows** - Should fire cannonballs
4. **Bomb tower fires arrows** - Should fire bombs with arc animation
5. **Flame animation needs improvement** - Both on flame tower and burning enemies
6. **Frost tower has premature animation** - Something animates before it shoots
7. **Laser tower not distinctive** - Hard to see what makes it unique
8. **Poison tower animation is weird** - Projectile needs work
9. **Poisoned enemies need visual effect** - Green translucent blob indicator
10. **Lightning should look like lightning** - Stretch from tower to target(s)

### Gameplay Issues:
1. **Poison tower wastes shots** - Should only target non-poisoned enemies

## Solution Statement
1. Fix the freeze tower bug by ensuring effects only apply to hit enemies
2. Update designer mode to bypass cost checks for tower selection
3. Improve designer mode button UX with clearer labeling
4. Create distinct projectile visuals for each tower type based on projectile_type config
5. Add proper effect indicators for poisoned enemies
6. Implement smart targeting for poison tower (skip already-poisoned targets)
7. Create lightning beam effect that stretches from tower to target
8. Improve flame/burn animations
9. Polish minion/walking bomb visual

## Relevant Files
Use these files to implement the feature:

- `lib/explore_web/live/game_live.ex` - Designer mode button and tower selection logic
  - Fix button label clarity
  - Bypass cost check in designer mode for tower selection

- `lib/explore_web/live/components/game_components.ex` - All visual components
  - Fix/improve projectile_visual for sniper (bullet), cannon (cannonball), bomb (arcing bomb)
  - Add poisoned effect indicator to enemy component
  - Improve minion visual (walking bomb)
  - Improve flame/burn effect visuals
  - Create lightning beam component (line from tower to target)
  - Add laser beam visual effect
  - Fix frost tower premature animation issue

- `lib/explore/game/tick.ex` - Game loop processing
  - Investigate freeze tower hang (likely in effect application)

- `lib/explore/game/combat/targeting.ex` - Target selection
  - Add poison avoidance targeting strategy or filter

- `lib/explore/game/entities/enemy.ex` - Enemy entity with effects
  - Verify effect application is correct
  - Add `has_effect?/2` function if missing (for poison check)

- `lib/explore/game/combat/effects.ex` - Effect definitions
  - Review slow/freeze effect handling

- `assets/css/app.css` - Animation styles
  - Improve flame animations
  - Add poison drip/bubble animation
  - Add lightning crackling animation
  - Improve walking bomb animation

### New Files
None required - only modifications to existing files.

## Implementation Plan
### Phase 1: Critical Bug Fixes
- Fix freeze tower hang bug (investigate tick.ex and effect application)
- Fix designer mode tower selection to bypass cost check
- Improve designer mode button UX

### Phase 2: Projectile Visual Overhaul
- Update projectile_visual to use projectile_type from tower config
- Create distinct visuals: bullet, cannonball, bomb (arcing), laser beam, lightning beam
- Fix poison glob animation

### Phase 3: Effect Visual Polish
- Add poison effect indicator on enemies (green blob)
- Improve burn/fire effect on enemies
- Improve slow/freeze effect visual
- Add lightning beam stretching from tower to target

### Phase 4: Smart Targeting
- Implement poison avoidance in targeting for poison tower

### Phase 5: Animation Polish
- Improve walking bomb minion visual
- Polish flame tower and flame effects
- Remove/fix frost tower premature animation

## Step by Step Tasks

### Step 1: Fix Freeze Tower Bug
- Read tick.ex effect application code carefully
- Trace the slow effect application path
- Identify why applying slow to one enemy affects all enemies
- Fix the bug ensuring effects only apply to the specific enemy hit
- Add test to verify isolated effect application

### Step 2: Fix Designer Mode Tower Selection
- In game_live.ex, update the tower button disabled logic
- When designer_mode is true, buttons should never be disabled
- Remove the `disabled={cost > resources}` when in designer mode

### Step 3: Improve Designer Mode Button UX
- Change button text from "Designer: ON/OFF" to clearer wording
- Option A: Use icon + "Designer Mode" with visual state indicator
- Option B: Show current state more clearly, e.g., "Designer Mode (Active)" vs "Enable Designer Mode"
- Make the button color more distinct when active

### Step 4: Create Projectile Type System
- Update projectile_visual to accept projectile_type parameter
- Read projectile_type from tower config via projectile
- Add new projectile_visual clauses for:
  - `:bullet` - small fast streak/tracer
  - `:cannonball` - round black ball
  - `:bomb` - bomb shape (may need arc path)
  - `:laser_beam` - continuous beam
  - `:lightning` - jagged line from tower to target

### Step 5: Update Sniper Tower Projectile
- Change sniper projectile from arrow to bullet
- Create sleek bullet/tracer visual
- Add motion blur effect in CSS

### Step 6: Update Cannon Tower Projectile
- Create round cannonball visual
- Black circle with highlight
- Maybe trailing smoke particles

### Step 7: Update Bomb Tower Projectile
- Create bomb visual (round with fuse)
- Consider adding slight arc to trajectory
- Should look like it's lobbing up and down

### Step 8: Improve Poison Projectile
- Create dripping glob visual
- Green translucent appearance
- Trailing drips

### Step 9: Add Poisoned Enemy Effect
- Add visual indicator when enemy has poison effect
- Two overlapping green translucent blobs
- Different shades of green
- Subtle dripping animation

### Step 10: Create Lightning Beam Effect
- Replace lightning projectile with beam from tower to target
- Jagged line that stretches between points
- Electric crackling animation
- Should chain to multiple targets visually

### Step 11: Improve Laser Tower Visual
- Make laser beam more visible and distinctive
- Continuous beam effect while firing
- Bright glow/bloom effect

### Step 12: Implement Poison Tower Smart Targeting
- Modify targeting.ex to add filter capability
- Create `not_poisoned` filter for poison tower
- Apply filter in find_target when tower has poison effects

### Step 13: Improve Flame/Burn Animations
- Enhance flame tower fire animation
- Improve burn effect on enemies
- More dynamic flickering
- Better color gradient

### Step 14: Fix Frost Tower Premature Animation
- Identify what's causing animation before shot
- Remove or fix the timing issue

### Step 15: Polish Walking Bomb Minion
- Improve bomb visual (rounder, cuter?)
- Better fuse animation
- Bouncy movement animation

### Step 16: Run Validation and Tests
- Run `mix format`
- Run `mix compile --warnings-as-errors`
- Run `mix test`
- Manual testing in browser

## Testing Strategy
Focus more on Integration Tests

### Unit Tests
- Test that enemy effects are properly isolated (freeze bug)
- Test poison targeting filter excludes poisoned enemies
- Test designer mode resource bypass logic

### Integration Tests
- Test frost tower doesn't cause hang when hitting multiple enemies
- Test poison tower targeting behavior with mixed poisoned/unpoisoned enemies
- Test designer mode allows tower selection regardless of resources

### Edge Cases
- Freeze effect on single enemy vs multiple enemies
- Poison tower with all enemies already poisoned (should find no target)
- Lightning chain to multiple targets visually
- Designer mode toggle during gameplay

## Acceptance Criteria
- [ ] Freeze tower does not cause game hang when hitting enemies
- [ ] Designer mode button clearly shows current state (not confusing)
- [ ] Can select any tower in designer mode regardless of gold
- [ ] Sniper tower fires bullet, not arrow
- [ ] Cannon tower fires cannonball, not arrow
- [ ] Bomb tower fires bomb projectile
- [ ] Poison tower only targets non-poisoned enemies
- [ ] Poisoned enemies show green blob effect
- [ ] Lightning visually stretches from tower to target(s)
- [ ] Laser tower has distinctive beam visual
- [ ] Walking bomb minion looks like a bomb
- [ ] Flame animations are improved
- [ ] No frost tower premature animation
- [ ] All tests pass
- [ ] No compiler warnings

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

Manual validation:
1. Open browser to http://localhost:4000/game
2. Enable Designer Mode - verify button shows clear state
3. Verify can select expensive towers even with 0 gold in designer mode
4. Place a frost tower - verify game doesn't hang when it hits enemies
5. Place a sniper tower - verify it fires bullets
6. Place a cannon tower - verify it fires cannonballs
7. Place a bomb tower - verify it fires bombs
8. Place a poison tower - verify green blobs on poisoned enemies
9. Verify poison tower skips already-poisoned enemies
10. Place a lightning tower - verify lightning stretches to targets
11. Place a laser tower - verify distinctive beam
12. Place a minion factory - verify walking bombs look correct

## Notes
- The freeze tower bug is likely in tick.ex where effects are applied - may be applying to all enemies in map instead of just the hit enemy
- Lightning beam will need special handling since it's not a traditional projectile - may need a separate "beam" entity or render directly from tower to target
- Bomb arc trajectory may be complex - could be done with CSS animation or SVG path
- Consider adding projectile_type to the projectile struct for cleaner rendering logic
