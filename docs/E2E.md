# E2E Testing

## E2E watchable run (RPA-style)

To validate that the interface works with real mouse/finger taps (the same way a user would interact), run E2E with the Simulator visibly in the foreground.

**Current watchable flow:** The run script builds the app, waits for the iOS Simulator to finish booting (so the Simulator window is ready and visible), then runs the E2E test. The UI tests use active waits for the menu (New Game button) and for the game HUD (turn label) instead of fixed sleeps, so the test proceeds only when the app is ready and the Simulator stays in sync with what you see.

**Simulator boot wait:** `scripts/wait-for-simulator.sh` uses `xcrun simctl bootstatus -b` to boot the device if needed and block until it is fully ready. On cold boot this may take 20–30 seconds; if the Simulator is already booted it returns immediately. The run script invokes this automatically before tests, so E2E tests start only after the Simulator is ready (per e2e_active_wait_and_simulator_boot plan).

---

### Option 1: Run script (command line)

**Main script (recommended):**

```bash
./scripts/run-e2e-watchable.sh
```

This script:

1. Builds the app for the target simulator (iPhone 16 by default).
2. Opens the Simulator app and waits for it to finish booting (`scripts/wait-for-simulator.sh`).
3. Runs the slow full-playthrough test (2s between moves) so you can watch.

**Quick mode** (400ms between taps):

```bash
./scripts/run-e2e-watchable.sh --quick
```

**Optional boot-wait only:** If you need to boot the Simulator in advance (e.g. cold boot before a manual run), you can run the boot-wait script by itself:

```bash
./scripts/wait-for-simulator.sh [device_name]
```

Example: `./scripts/wait-for-simulator.sh "iPhone 16"`. Default device is `iPhone 16` if omitted. The script opens Simulator and blocks until `simctl bootstatus` reports the device booted.

---

### Option 2: Run from Xcode

1. Open the project in Xcode.
2. Select the **TableTopGame** scheme and an iPhone simulator (e.g. iPhone 16).
3. **Product → Test**, or run only `testFullPlaythroughUntilGameOverSlow` (or `testFullPlaythroughUntilGameOver` for quick) from the Test Navigator.

Xcode keeps the Simulator visible when running tests. Ensure the Simulator has finished booting before starting the test run (e.g. boot it first or run tests after a fresh launch).
