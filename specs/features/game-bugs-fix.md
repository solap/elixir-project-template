# Feature: Fix Game Critical Bugs

## Feature Description
Fix multiple critical bugs preventing the tower defense game from functioning correctly: the path loops back on itself, the path goes off screen, waves don't start when clicking "Start Wave", and towers cannot be placed.

## User Story
As a player
I want the game to work correctly with a proper path, functional wave system, and working tower placement
So that I can actually play the tower defense game

## Problem Statement
Four critical bugs are preventing gameplay:

1. **Path loops on itself**: The windy path waypoints visit `(500, 200)` twice, creating a visual loop. The path also visits points like `(200, 300)` twice.
2. **Path goes off screen**: Some waypoints extend beyond the map boundaries (map is 600 height but waypoints go to y=500).
3. **Start Wave button doesn't work**: Clicking "Start Wave" does nothing - likely due to wave config loading issues or state management problems.
4. **Cannot place towers**: Tower placement fails - likely due to mouse position tracking issues (SVG coordinate transformation) or grid/placement validation.

## Solution Statement
1. **Fix path**: Redesign the windy path YAML to create a proper S-curve that:
   - Does not loop back on itself
   - Stays within map bounds (800x600)
   - Provides adequate space for tower placement

2. **Fix wave system**: Debug and fix the wave starting mechanism:
   - Ensure level config loads correctly
   - Verify WaveConfig.get_wave returns proper data
   - Check state transitions work correctly

3. **Fix tower placement**: Fix the coordinate transformation:
   - The mouse position tracking needs to account for SVG viewBox scaling
   - Ensure click handler properly receives and passes coordinates

## Relevant Files
Use these files to implement the feature:

- `priv/game_config/maps/windy_path.yml` - Path waypoint configuration that needs fixing
- `lib/explore/game/map/maps/windy_path.ex` - Hardcoded fallback path that needs matching updates
- `lib/explore_web/live/game_live.ex` - LiveView handling events and mouse tracking
- `assets/js/app.js` - JavaScript hooks for mouse position tracking
- `lib/explore/game/engine.ex` - Game engine handling start_wave and place_tower
- `lib/explore/game/config/wave_config.ex` - Wave configuration loading
- `lib/explore/game/map/game_map.ex` - Map and placement logic

### New Files
None required - only modifications to existing files.

## Implementation Plan
### Phase 1: Foundation
- Analyze the exact path coordinates causing the loop
- Understand the SVG coordinate system and scaling

### Phase 2: Core Implementation
- Fix the path waypoints to create a proper non-looping S-curve
- Fix the JavaScript hook to correctly transform mouse coordinates
- Add debugging to wave system to identify why waves don't start

### Phase 3: Integration
- Test the complete flow: path display, tower placement, wave starting
- Verify all functionality works together

## Step by Step Tasks

### Step 1: Fix the Path Configuration
- Update `priv/game_config/maps/windy_path.yml` with new waypoints that:
  - Start at (0, 300) - left edge, middle
  - Wind through the map without crossing itself
  - Stay within bounds (0-800 x, 0-600 y)
  - End at (800, 300) - right edge, middle
- Update `lib/explore/game/map/maps/windy_path.ex` with matching waypoints

### Step 2: Fix SVG Mouse Coordinate Transformation
- Modify `assets/js/app.js` GameBoard hook to:
  - Get the SVG element's viewBox dimensions
  - Calculate the proper scale factor between viewport and viewBox
  - Transform mouse coordinates to SVG space before sending to server

### Step 3: Fix Click Handler for Tower Placement
- Update `lib/explore_web/live/game_live.ex` to:
  - Properly receive and parse coordinates from the click event
  - Fix the phx-value-x/y on the click overlay to use SVG coordinates

### Step 4: Debug Wave System
- Add IO.inspect debugging to `handle_call(:start_wave, ...)` in engine.ex
- Verify WaveConfig.get_wave returns valid data
- Check that level_config is properly loaded

### Step 5: Run Tests and Validation
- Run `mix format`
- Run `mix compile --warnings-as-errors`
- Run `mix test`
- Start the server and manually test:
  - Path displays correctly without loops
  - Tower can be selected and placed
  - Start Wave button works and spawns enemies

## Testing Strategy
Focus more on Integration Tests

### Unit Tests
- Test path waypoint validation (no duplicates, within bounds)
- Test grid coordinate transformation functions

### Integration Tests
- Test full game flow from mount to wave completion
- Test tower placement at various positions
- Test path rendering and enemy movement

### Edge Cases
- Mouse at edges of game board
- Clicking on path (should not allow placement)
- Clicking outside valid grid
- Starting wave when already playing

## Acceptance Criteria
- [ ] Path displays as a smooth S-curve from left to right without loops
- [ ] Path stays completely within the 800x600 map bounds
- [ ] Clicking "Start Wave" begins wave 1 and spawns enemies
- [ ] Enemies spawn at the path start and move along the path
- [ ] Tower can be selected from the panel
- [ ] Clicking on valid grid positions places the selected tower
- [ ] Tower placement shows range indicator following mouse
- [ ] Placed towers are visible and positioned correctly

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
1. Navigate to http://localhost:4000/game
2. Verify path is visible without loops
3. Select "Arrow Tower" from panel
4. Click on valid position (not on path) - tower should be placed
5. Click "Start Wave 1" button - enemies should appear
6. Verify enemies move along path from left to right

## Notes
- The SVG viewBox is "0 0 800 600" but the actual div may be different size due to CSS
- Mouse coordinates from JavaScript are in viewport space, need transformation to SVG space
- The path should provide good coverage of tower placement areas while leaving space for strategy
- Consider adding visual feedback when placement is invalid (already partially implemented with red indicator)
