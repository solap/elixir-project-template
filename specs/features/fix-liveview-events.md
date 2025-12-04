# Feature: Fix LiveView Events Not Working

## Feature Description
Fix critical bugs where clicking "Start Wave" button and tower placement do not work in the browser. The server-side logic works correctly when tested directly via `mix run`, but user interactions in the browser have no effect.

## User Story
As a player
I want to click the Start Wave button and have it work
So that I can play the tower defense game

## Problem Statement
Two critical interactive features don't work:
1. Clicking "Start Wave 1" button has no effect
2. Clicking on the game board to place towers has no effect

The server-side code (Engine.start_wave, Engine.place_tower) works correctly when tested directly. This indicates the problem is in the client-server communication:
- LiveSocket may not be connected
- Events may not be reaching the server
- JavaScript hooks may have errors
- Event handlers may not be properly attached

## Solution Statement
1. Add logging/debugging to identify where the communication breaks
2. Ensure LiveSocket is properly connected with debug enabled
3. Fix any JavaScript errors preventing event handling
4. Ensure the game components properly handle interactivity

## Relevant Files
Use these files to implement the feature:

- `assets/js/app.js` - LiveSocket configuration and hooks
- `lib/explore_web/live/game_live.ex` - LiveView event handlers
- `lib/explore_web/components/layouts/root.html.heex` - Root layout with JS inclusion
- `lib/explore_web/endpoint.ex` - WebSocket endpoint configuration
- `config/config.exs` - App configuration

### New Files
None required - only modifications to existing files.

## Implementation Plan
### Phase 1: Foundation
- Enable LiveSocket debugging to see connection status
- Add console logging to trace event flow

### Phase 2: Core Implementation
- Fix LiveSocket connection issues
- Ensure events properly reach the server
- Test and verify each fix incrementally

### Phase 3: Integration
- Remove debug logging
- Verify all features work together

## Step by Step Tasks

### Step 1: Enable LiveView Debug Mode
- Add `debug: true` to LiveSocket configuration in app.js
- This will show connection status and event flow in browser console

### Step 2: Add Console Logging to Event Handlers
- Add console.log to the click handler in GameBoard hook
- Add console.log to verify events are being pushed

### Step 3: Fix Potential LiveSocket Connection Issues
- Ensure LiveSocket is connecting successfully
- Check for any JavaScript errors on page load

### Step 4: Verify Event Handler Registration
- Ensure phx-click events are properly bound
- Check that the button is not disabled or hidden

### Step 5: Run Tests and Validation
- Run `mix format`
- Run `mix compile --warnings-as-errors`
- Run `mix test`
- Start server and manually test in browser

## Testing Strategy
Focus more on Integration Tests

### Unit Tests
- None needed - this is a runtime/connection issue

### Integration Tests
- Test LiveView mount and state initialization
- Test event handling round-trip

### Edge Cases
- WebSocket connection failure
- Slow network conditions

## Acceptance Criteria
- [ ] Clicking "Start Wave 1" button starts the wave
- [ ] Enemies appear and move along the path after wave starts
- [ ] Clicking on valid positions with tower selected places tower
- [ ] Tower appears at clicked location
- [ ] Browser console shows successful LiveSocket connection

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
2. Open browser DevTools console
3. Verify LiveSocket connection message appears
4. Click "Start Wave 1" button
5. Verify wave starts and enemies spawn
6. Select a tower and click on the map
7. Verify tower is placed

## Notes
- The issue is likely a disconnect between client and server
- Server-side code has been verified to work correctly
- Need to trace the event flow from click to server handler
- Browser DevTools will be essential for debugging
