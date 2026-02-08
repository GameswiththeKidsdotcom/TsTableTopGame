#!/bin/bash
# Run E2E tests with Simulator in the foreground so you can watch the taps.
# Validates the interface works with real mouse/finger interactions (RPA-style).
set -e

cd "$(dirname "$0")/.."
DEST="platform=iOS Simulator,name=iPhone 16"

QUICK=false
for arg in "$@"; do
  case "$arg" in
    --quick) QUICK=true ;;
  esac
done

if [ "$QUICK" = true ]; then
  TEST="TableTopGameUITests/testFullPlaythroughUntilGameOver"
  echo "Using quick test (400ms between taps)"
else
  TEST="TableTopGameUITests/testFullPlaythroughUntilGameOverSlow"
  echo "Using slow test (2s between taps - watch the Simulator)"
fi

echo "Building..."
xcodebuild -scheme TableTopGame -destination "$DEST" build

echo "Bringing Simulator to foreground..."
open -a Simulator
sleep 1
osascript -e 'tell application "Simulator" to activate'
sleep 2

echo "Running E2E (watch the Simulator)..."
xcodebuild -scheme TableTopGame -destination "$DEST" \
  -only-testing:"$TEST" \
  test
