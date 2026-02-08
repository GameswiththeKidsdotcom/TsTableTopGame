# E2E Testing

## E2E watchable run (RPA-style)

To validate that the interface works with real mouse/finger taps (the same way a user would interact), run E2E with the Simulator visibly in the foreground.

### Option 1: Run script (command line)

```bash
./scripts/run-e2e-watchable.sh
```

This script:
1. Builds first
2. Brings Simulator to the foreground
3. Runs the slow full-playthrough test (2s between moves) so you can watch

**Quick mode** (400ms between taps):
```bash
./scripts/run-e2e-watchable.sh --quick
```

### Option 2: Run from Xcode

1. Open the project in Xcode
2. Select the TableTopGame scheme and an iPhone simulator
3. Product > Test, or run only `testFullPlaythroughUntilGameOverSlow` from the Test Navigator

Xcode keeps the Simulator visible when running tests.
