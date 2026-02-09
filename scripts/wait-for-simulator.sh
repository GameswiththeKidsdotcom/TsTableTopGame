#!/bin/bash
# Wait for iOS Simulator to finish booting before running tests.
# Per e2e_active_wait_and_simulator_boot plan (B1).
# Usage: ./wait-for-simulator.sh [device_name]
#   device_name: e.g. "iPhone 16" (default)
set -e

DEVICE_NAME="${1:-iPhone 16}"

# Resolve device name to UDID (exact match: "iPhone 16" not "iPhone 16 Pro")
# Match "DeviceName (" to avoid "DeviceName Pro" etc.
get_udid() {
  xcrun simctl list devices available 2>/dev/null | \
    grep -F "$DEVICE_NAME (" | head -1 | \
    grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' | head -1
}

UDID=$(get_udid)
if [ -z "$UDID" ]; then
  echo "Error: No available simulator found for '$DEVICE_NAME'" >&2
  echo "Run: xcrun simctl list devices available" >&2
  exit 1
fi

echo "Simulator: $DEVICE_NAME ($UDID)"
echo "Opening Simulator app..."
open -a Simulator
sleep 1
osascript -e 'tell application "Simulator" to activate' 2>/dev/null || true

echo "Waiting for Simulator to finish booting (bootstatus -b)..."
xcrun simctl bootstatus "$UDID" -b
echo "Simulator ready."
