#!/bin/sh
set -u
export EXACT_FEEDBACK=0
cd "$(dirname "$0")"; mkdir -p .exact
bun exact.mjs agent web --storage a "tap open" "clock settle" "screenshot .exact/menu-all.png" >/dev/null 2>&1 || { echo "FAIL setup"; exit 2; }
out=$(bun exact.mjs agent web --storage b "tap open" "tap active" "clock settle" "tap open" "clock settle" \
  "screenshot .exact/menu-active.png compare .exact/menu-all.png" 2>&1) || { echo "FAIL setup"; echo "$out"; exit 2; }
regions=$(printf '%s\n' "$out" | grep -E '^  [0-9]+ \[')
[ -n "$regions" ] || { echo "FAIL setup: the \"Showing\" label should differ"; echo "$out"; exit 2; }
others=$(printf '%s\n' "$regions" | grep -v 'under showing' | grep -c .)
if [ "$others" -eq 0 ]; then
  echo "BUG: the menu looks the same with All or Active checked; only the label differs:"
  printf '%s\n' "$regions"; exit 1
fi
echo "FIXED: the menu marks the checked item"
