#!/bin/bash
# coverage-gate.sh — extract coverage metrics from .xcresult, apply REQ-007 exclusions,
# fail < 80%, warn < 90%.
set -euo pipefail

XCRESULT="${1:?Usage: coverage-gate.sh <path-to-xcresult>}"
THRESHOLD=80
DESIRABLE=90

COVERAGE_FILE=$(mktemp /tmp/coverage-gate.XXXXXX)
trap 'rm -f "$COVERAGE_FILE"' EXIT

# Export coverage: xccov (primary, widely supported)
if ! xcrun xccov view --report --json "$XCRESULT" > "$COVERAGE_FILE" 2>/dev/null; then
  echo "ERROR: cannot extract coverage from $XCRESULT" >&2
  exit 1
fi

# REQ-007 exclusion patterns (relative to "CrowdSec Monitor/" source directory)
EXCLUSIONS='Views/|Models/|Core/CrowdSec_MonitorApp\.swift|Core/Persistence\.swift|Core/CSServerMigrationPolicy\.swift|Core/CSServer\.swift|Constants/AppIcon\.swift|Constants/ColorsList\.swift|Constants/URLs\.swift|Constants/IAPIds\.swift|\.icon/|Utils/SharedAppStorage\.swift|Extensions/ViewExtension\.swift|SourcePackages/'

python3 -c "
import json, re, sys

with open('${COVERAGE_FILE}') as f:
    raw = f.read().strip()
    if not raw:
        print('ERROR: empty coverage data', file=sys.stderr)
        sys.exit(1)

data = json.loads(raw)

# xccov --report --json returns {\"coveredLines\": N, \"executableLines\": N, \"targets\": [{\"files\": [...]}]}
files = []
if isinstance(data, dict):
    for t in data.get('targets', []):
        if 'Tests' in t.get('name', ''):
            continue
        files.extend(t.get('files', []))

EXCLUSIONS = re.compile(r'${EXCLUSIONS}')
TEST_RE = re.compile(r'/CrowdSec Monitor(UI)?Tests/')
SP_RE = re.compile(r'/SourcePackages/')

def should_exclude(path):
    if TEST_RE.search(path) or SP_RE.search(path):
        return True
    m = re.search(r'CrowdSec Monitor[/\\\\](.*)', path)
    if not m:
        return False
    rel = m.group(1)
    return bool(EXCLUSIONS.search(rel))

# Aggregate per-file coverage
total_lines = 0
covered_lines = 0
total_functions = 0
covered_functions = 0

for f in files:
    path = f.get('path', '')
    if should_exclude(path):
        continue

    # Lines: executableLines + coveredLines
    el = f.get('executableLines', 0)
    cl = f.get('coveredLines', 0)
    if el > 0:
        total_lines += el
        covered_lines += cl

    # Functions: count from nested 'functions' array
    funcs = f.get('functions', [])
    for fn in funcs:
        if fn.get('executableLines', 0) > 0:
            total_functions += 1
            if fn.get('executionCount', 0) > 0:
                covered_functions += 1

line_pct = (covered_lines * 100.0 / total_lines) if total_lines > 0 else 0.0
func_pct = (covered_functions * 100.0 / total_functions) if total_functions > 0 else 0.0
# Branch coverage not available in xccov JSON export; mark as such
# Statements ≈ lines in Swift/Xcode model
stmt_pct = line_pct

line = f'lines: {line_pct:.0f}% | functions: {func_pct:.0f}% | branches: N/A | statements: {stmt_pct:.0f}%'
print(line, file=sys.stderr)

if total_lines == 0 and total_functions == 0:
    print('WARN: no testable source files found (all excluded?)', file=sys.stderr)
    sys.exit(0)

TH = ${THRESHOLD}
DH = ${DESIRABLE}
exit_code = 0
checks = [('lines', line_pct), ('functions', func_pct), ('statements', stmt_pct)]
for name, val in checks:
    if val < TH:
        print(f'FAIL: {name} coverage ({val:.0f}%) < {TH}%', file=sys.stderr)
        exit_code = 1
    elif val < DH:
        print(f'WARN: {name} coverage ({val:.0f}%) < {DH}%', file=sys.stderr)

sys.exit(exit_code)
"
