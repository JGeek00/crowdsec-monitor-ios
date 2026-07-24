#!/bin/bash
set -euo pipefail

# coverage-gate.sh — Extract coverage from .xcresult, apply exclusions,
# fail if any metric < 80%, warn if < 90%.
#
# Usage: ./scripts/coverage-gate.sh <path/to/Test.xcresult>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <xcresult-path>" >&2
    exit 1
fi

XCRESULT="$1"
if [ ! -d "$XCRESULT" ]; then
    echo "Error: .xcresult bundle not found at $XCRESULT" >&2
    exit 1
fi

# Excluded path prefixes (REQ-007, see data-model.md)
EXCLUDE_PATTERNS=(
    "Views/"
    "Models/"
    "Core/CrowdSec_MonitorApp.swift"
    "Core/Persistence.swift"
    "Core/CSServerMigrationPolicy.swift"
    "Core/CSServer.swift"
    "Constants/AppIcon.swift"
    "Constants/ColorsList.swift"
    "Constants/URLs.swift"
    "Constants/IAPIds.swift"
)

# Extract coverage JSON. Probe xcresulttool version for compatible invocation.
# xcrun xcresulttool export --legacy works on Xcode 15+; fallback to get export.
COVERAGE_JSON=$(mktemp)
trap 'rm -f "$COVERAGE_JSON"' EXIT

if xcrun xcresulttool export --legacy --type directory --path "$XCRESULT" --output-path "$COVERAGE_JSON" 2>/dev/null; then
    : # legacy export succeeded
elif xcrun xcresulttool get --legacy --path "$XCRESULT" --output-path "$COVERAGE_JSON" 2>/dev/null; then
    : # alternative
else
    echo "Warning: could not extract coverage data; xcresulttool invocation may vary by Xcode version" >&2
    echo "lines: 0% | functions: 0% | branches: 0% | statements: 0%"
    echo "FAIL — coverage data unavailable"
    exit 1
fi

# The coverage data is in a known subpath within the export.
# Look for the coverage archive file.
COV_FILE=$(find "$COVERAGE_JSON" -name "*.json" -path "*Coverage*" 2>/dev/null | head -1)
if [ -z "$COV_FILE" ]; then
    # Try default.json at root of export
    COV_FILE="$COVERAGE_JSON/default.json"
    if [ ! -f "$COV_FILE" ]; then
        COV_FILE="$COVERAGE_JSON/action.json"
    fi
    if [ ! -f "$COV_FILE" ]; then
        # The export structure varies — try any JSON
        COV_FILE=$(find "$COVERAGE_JSON" -name "*.json" 2>/dev/null | head -1)
    fi
fi

if [ -z "$COV_FILE" ] || [ ! -f "$COV_FILE" ]; then
    echo "Warning: coverage JSON not found in xcresulttool export" >&2
    echo "lines: 0% | functions: 0% | branches: 0% | statements: 0%"
    echo "FAIL — coverage data unavailable"
    exit 1
fi

# Parse per-file coverage from the JSON.
# The JSON structure from xcresulttool export is a coverage archive with
# per-file entries containing line/function/branch coverage.
#
# Using Python for robust JSON parsing.
python3 - "$COV_FILE" "${EXCLUDE_PATTERNS[@]}" <<'PYEOF' || exit $?
import json
import sys
import os

cov_file = sys.argv[1]
exclude_patterns = sys.argv[2:]

with open(cov_file) as f:
    data = json.load(f)

# Navigate to the coverage data. The structure varies by Xcode version.
# Common paths: data["coverage"] or data["files"] or direct array.
files = []

if isinstance(data, list):
    files = data
elif isinstance(data, dict):
    # Try known key paths
    for key in ("files", "coverage", "coveredLines", "data"):
        if key in data:
            val = data[key]
            if isinstance(val, list):
                files = val
                break
            elif isinstance(val, dict) and "files" in val:
                files = val["files"]
                break

if not files:
    # Last resort — search any array in the JSON
    def find_array(obj, depth=0):
        if depth > 5:
            return None
        if isinstance(obj, dict):
            for v in obj.values():
                result = find_array(v, depth + 1)
                if result:
                    return result
        elif isinstance(obj, list) and len(obj) > 0 and isinstance(obj[0], dict) and "lineCoverage" in obj[0]:
            return obj
        return None
    files = find_array(data) or []

if not files:
    print("Warning: no per-file coverage data found in xcresulttool export", file=sys.stderr)
    # Try xccov alternative
    print("lines: 0% | functions: 0% | branches: 0% | statements: 0%")
    print("FAIL — coverage data unavailable")
    sys.exit(1)

def should_exclude(path):
    for pattern in exclude_patterns:
        if path.startswith(pattern) or pattern in path:
            return True
    return False

total_lines = 0
covered_lines = 0
total_functions = 0
covered_functions = 0
total_branches = 0
covered_branches = 0

for f in files:
    path = f.get("name") or f.get("path") or ""
    # Normalize path: strip leading /Users/.../CrowdSec Monitor/
    # The coverage JSON often contains full absolute paths.
    rel_path = path
    if "CrowdSec Monitor/" in rel_path:
        idx = rel_path.index("CrowdSec Monitor/") + len("CrowdSec Monitor/")
        rel_path = rel_path[idx:]

    if should_exclude(rel_path):
        continue

    # Line coverage
    lc = f.get("lineCoverage")
    if lc is not None:
        total_lines += 1
        if lc > 0:
            covered_lines += 1

    # Function coverage (some Xcode versions report per-function)
    funcs = f.get("functions", [])
    for func in funcs:
        if func.get("lineCoverage") is not None:
            total_functions += 1
            if func["lineCoverage"] > 0:
                covered_functions += 1
        elif func.get("coveredLines") is not None:
            total_functions += 1
            if func["coveredLines"] > 0:
                covered_functions += 1

    # Branch coverage
    branches = f.get("branches", [])
    for b in branches:
        if b.get("lineCoverage") is not None:
            total_branches += 1
            if b["lineCoverage"] > 0:
                covered_branches += 1

# If the above per-file approach didn't find data, try the aggregate values
if total_lines == 0:
    # Use lineCoverage from individual file entries directly
    for f in files:
        path = f.get("name") or f.get("path") or ""
        rel_path = path
        if "CrowdSec Monitor/" in rel_path:
            idx = rel_path.index("CrowdSec Monitor/") + len("CrowdSec Monitor/")
            rel_path = rel_path[idx:]
        if should_exclude(rel_path):
            continue
        lc = f.get("lineCoverage")
        if lc is not None:
            total_lines += 1
            if lc > 0:
                covered_lines += 1

    # Fallback to aggregate: some xcresulttool exports give aggregate values
    agg = data.get("lineCoverage")
    if agg is not None and total_lines == 0:
        covered_lines = int(agg * 100)
        total_lines = 100

lines_pct = (covered_lines / total_lines * 100) if total_lines > 0 else 0
funcs_pct = (covered_functions / total_functions * 100) if total_functions > 0 else 0
branches_pct = (covered_branches / total_branches * 100) if total_branches > 0 else 0
# Statement ≈ line in Swift
statements_pct = lines_pct

print(f"lines: {lines_pct:.0f}% | functions: {funcs_pct:.0f}% | branches: {branches_pct:.0f}% | statements: {statements_pct:.0f}%")

all_pass = True
for name, pct in [("lines", lines_pct), ("functions", funcs_pct), ("branches", branches_pct), ("statements", statements_pct)]:
    if pct < 80:
        print(f"FAIL — {name}: {pct:.0f}% < 80%")
        all_pass = False
    elif pct < 90:
        print(f"WARNING — {name}: {pct:.0f}% < 90% (desirable target)")

if all_pass:
    print("PASS — all metrics ≥ 80%")
    sys.exit(0)
else:
    sys.exit(1)
PYEOF
