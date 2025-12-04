# Feature: Comprehensive Game Bug Fix

## Feature Description
Fix critical bugs preventing the tower defense game from functioning in the browser. The user reports:
1. No panel showing on the right (or anywhere)
2. Creatures don't walk across the path when pressing Start Wave
3. Towers don't appear on the map when clicking

Investigation shows that server-side HTML is rendering correctly with the tower panel, Arrow Tower button, and SVG game board. The issues appear to be related to client-side rendering, WebSocket connectivity, or browser caching.

## User Story
As a player
I want the game to work correctly in my browser
So that I can play the tower defense game

## Problem Statement
The game appears broken in the browser despite server-side logic working correctly:
1. **Panel not visible**: HTML shows `<div class="w-64">` with tower selection, but user doesn't see it
2. **Start Wave not working**: phx-click event doesn't trigger wave spawn
3. **Tower placement not working**: Click events don't result in towers appearing

Server logs show:
- `>>> MOUNT called, connected: false` (HTTP mount works)
- `>>> Available towers: [:arrow_tower]` (Data is correct)
- No WebSocket mount log (connected: true) - indicating possible WebSocket connection failure

## Solution Statement
1. Ensure WebSocket connection establishes properly
2. Add diagnostic visibility to troubleshoot browser issues
3. Verify CSS and JavaScript are not cached/stale
4. Add visible error handling for connection issues

## Relevant Files
Use these files to implement the feature:

- `assets/js/app.js` - LiveSocket configuration, hooks, WebSocket connection
  - Verify hooks are registered correctly
  - Add connection status indicators
  - Check for JavaScript errors

- `lib/explore_web/live/game_live.ex` - Main game LiveView
  - Handle WebSocket connection state
  - Verify state updates broadcast correctly

- `lib/explore_web/live/components/game_components.ex` - Game rendering components
  - Ensure SVG renders enemies and towers correctly

- `lib/explore/game/engine.ex` - Game state management
  - Verify wave spawning works
  - Check PubSub broadcasting

- `assets/css/app.css` - Styling
  - Ensure tower-button and panel classes are present

### New Files
None required.

## Implementation Plan

### Phase 1: Diagnostics
- Add visible connection status indicator to the page
- Log JavaScript errors to diagnose client-side issues
- Verify assets are being rebuilt and served fresh

### Phase 2: Connection Fix
- Ensure LiveSocket connects via WebSocket
- Verify phx-click events are being sent
- Confirm server receives events and broadcasts updates

### Phase 3: State Update Fix
- Verify PubSub is broadcasting state changes
- Ensure LiveView re-renders on state changes
- Confirm enemies/towers appear in SVG when added to state

## Step by Step Tasks

### Step 1: Add Visible Connection Status Indicator
- Add a connection status banner to game_live.ex
- Shows "Connected" or "Disconnected" in the UI
- Helps diagnose if WebSocket is establishing

### Step 2: Add JavaScript Error Handling
- Wrap LiveSocket connection in try/catch
- Log connection events to console
- Add global error handler to catch script errors

### Step 3: Force Asset Rebuild
- Clear compiled assets: `rm -rf priv/static/assets/*`
- Rebuild: `mix assets.deploy`
- Add cache-busting to HTML if needed

### Step 4: Verify WebSocket Mount Triggers
- Add IO.puts for connected: true mount
- Ensure second mount happens when WebSocket connects
- Debug why WebSocket might not be connecting

### Step 5: Test PubSub Broadcasting
- Add logging to broadcast functions
- Verify state_updated message is sent after wave starts
- Verify handle_info receives the broadcast

### Step 6: Run Validation Commands
- `mix format`
- `mix compile --warnings-as-errors`
- `mix test`
- Start server and test in browser with DevTools open

## Testing Strategy
Focus more on Integration Tests

### Unit Tests
- Test Engine.start_wave spawns enemies
- Test World.add_enemy adds to enemies map
- Test state broadcasting via PubSub

### Integration Tests
- Test LiveView mounts correctly
- Test event handlers receive and process events
- Test state updates cause re-renders

### Edge Cases
- WebSocket connection timeout
- Browser cache preventing new code from loading
- Multiple rapid clicks before state updates

## Acceptance Criteria
- [ ] User sees tower panel on the right side of the screen
- [ ] User sees Arrow Tower button with cost displayed
- [ ] Clicking Start Wave spawns enemies that move along path
- [ ] Selecting tower and clicking map places tower
- [ ] Browser DevTools shows no JavaScript errors
- [ ] Server logs show both disconnected and connected mounts

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

```bash
# Clear old assets
rm -rf priv/static/assets/*.js priv/static/assets/*.css

# Format code
mix format

# Compile without warnings
mix compile --warnings-as-errors

# Run all tests
mix test

# Rebuild assets
mix assets.deploy

# Start server
mix phx.server
```

Manual validation:
1. Open http://localhost:4000/game in a fresh browser window (or incognito)
2. Open Browser DevTools (F12) → Console tab
3. Look for "LiveSocket connected!" message
4. Look for any JavaScript errors (red text)
5. Verify tower panel shows on the right
6. Click "Arrow Tower" button - verify it highlights
7. Click on the game board - verify tower appears
8. Click "Start Wave 1" - verify enemies spawn and move

## Notes
- The server-side code IS working - HTML contains correct content
- Issue is likely browser-side: caching, WebSocket, or JavaScript error
- User should try: Hard refresh (Cmd+Shift+R / Ctrl+Shift+R), Incognito window
- Check browser DevTools console for JavaScript errors
- Check Network tab to verify WebSocket connection (ws://localhost:4000/live/websocket)
