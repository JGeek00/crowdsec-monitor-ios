#!/bin/bash
# test.sh — canonical test runner for the iOS app.
#
# Usage:
#   scripts/test.sh [--ui] [--coverage] [--destination <xcodebuild destination>] [-- extra xcodebuild args...]
#
# Default: unit tests only, code coverage OFF (~2-3 min total).
#   --ui        include UI tests (~7 min total: each UI test boots a simulator
#               clone and launches the app, 1-3 min per test).
#   --coverage  enable code coverage (the shared test plan defaults to ON).
#               WARNING: with coverage enabled and a large suite, xcodebuild may
#               hang after "Executed N tests" while processing coverage data.
#
# AGENTS: run this with a timeout >= 15 min or in the background, and let it
# finish — killing xcodebuild mid-run leaves a corrupt .xcresult and wedges
# the simulator/build services.
#
# The default destination is a clean iPhone 17e simulator, not the developer's
# configured device. Unit tests are hermetic, so any simulator works for them;
# UI tests observe app state (onboarding appears only on a device with no
# completed onboarding).
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCHEME="CrowdSec Monitor"
PROJECT="$PROJECT_DIR/CrowdSec Monitor.xcodeproj"
DESTINATION="${IOS_TEST_DESTINATION:-platform=iOS Simulator,name=iPhone 17e}"

RUN_UI=0
COVERAGE=(-enableCodeCoverage NO)
EXTRA_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ui) RUN_UI=1; shift ;;
    --coverage) COVERAGE=(); shift ;;
    --destination) DESTINATION="$2"; shift 2 ;;
    --) shift; EXTRA_ARGS=("$@"); break ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

ARGS=(
  test
  -project "$PROJECT"
  -scheme "$SCHEME"
  -destination "$DESTINATION"
  -parallel-testing-enabled NO
  "${COVERAGE[@]+"${COVERAGE[@]}"}"
)

if [[ $RUN_UI -eq 0 ]]; then
  ARGS+=(-skip-testing:"CrowdSec MonitorUITests")
fi

cd "$PROJECT_DIR"
exec xcodebuild "${ARGS[@]}" "${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}"
