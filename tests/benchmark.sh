#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Performance benchmark: whichx vs old.which
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
WHICHX="$SCRIPT_DIR/../whichx"
OLDWHICH="$SCRIPT_DIR/../old.which"

if [[ ! -x "$OLDWHICH" ]]; then
  echo "Error: old.which not found at $OLDWHICH" >&2
  exit 1
fi

# Benchmark function: runs command N times, returns milliseconds
# Usage: benchmark <iterations> <command> [args...]
benchmark() {
  local -i iterations=$1
  shift
  local start end elapsed
  start=$(date +%s%N)
  for ((i=0; i<iterations; i++)); do
    "$@" >/dev/null 2>&1 || true
  done
  end=$(date +%s%N)
  elapsed=$(( (end - start) / 1000000 ))
  echo "$elapsed"
}

# Print formatted result
# Usage: result <test_name> <whichx_ms> <oldwhich_ms> <iterations>
result() {
  local name=$1
  local -i wx_ms=$2 ow_ms=$3 iters=$4
  local wx_ops ow_ops ratio winner

  if ((wx_ms > 0)); then
    wx_ops=$(echo "scale=1; $iters * 1000 / $wx_ms" | bc)
  else
    wx_ops="inf"
  fi

  if ((ow_ms > 0)); then
    ow_ops=$(echo "scale=1; $iters * 1000 / $ow_ms" | bc)
  else
    ow_ops="inf"
  fi

  if ((wx_ms <= ow_ms)); then
    ratio=$(echo "scale=2; $ow_ms / ($wx_ms + 0.001)" | bc 2>/dev/null || echo "1.00")
    winner="whichx"
  else
    ratio=$(echo "scale=2; $wx_ms / ($ow_ms + 0.001)" | bc 2>/dev/null || echo "1.00")
    winner="old.which"
  fi

  printf '%-25s %8d ms (%6s ops/s)  %8d ms (%6s ops/s)  %sx %s\n' \
    "$name" "$wx_ms" "$wx_ops" "$ow_ms" "$ow_ops" "$ratio" "$winner"
}

# Setup test environment
setup() {
  TESTDIR=$(mktemp -d)
  trap 'rm -rf "$TESTDIR"' EXIT

  # Create test executables in multiple directories
  for i in {1..50}; do
    mkdir -p "$TESTDIR/bin$i"
    printf '#!/bin/sh\necho test' > "$TESTDIR/bin$i/testcmd"
    chmod +x "$TESTDIR/bin$i/testcmd"
  done

  # Build large PATH (include system dirs for tools)
  LARGEPATH=""
  for i in {1..50}; do
    LARGEPATH+="$TESTDIR/bin$i:"
  done
  LARGEPATH+="/usr/bin:/bin"
}

run_benchmarks() {
  echo "# whichx vs old.which benchmark"
  echo "#"
  printf '%-25s %25s  %25s  %s\n' "Test" "whichx" "old.which" "Winner"
  echo "# $(printf '%.0s-' {1..95})"

  local -i wx_ms ow_ms iters

  # Test 1: Single command lookup
  iters=1000
  wx_ms=$(benchmark $iters "$WHICHX" ls)
  ow_ms=$(benchmark $iters "$OLDWHICH" ls)
  result "Single lookup" "$wx_ms" "$ow_ms" "$iters"

  # Test 2: Multiple commands
  iters=200
  wx_ms=$(benchmark $iters "$WHICHX" ls cat grep sed awk)
  ow_ms=$(benchmark $iters "$OLDWHICH" ls cat grep sed awk)
  result "5 commands" "$wx_ms" "$ow_ms" "$iters"

  # Test 3: -a all matches
  iters=500
  wx_ms=$(PATH="$LARGEPATH" benchmark $iters "$WHICHX" -a testcmd)
  ow_ms=$(PATH="$LARGEPATH" benchmark $iters "$OLDWHICH" -a testcmd)
  result "-a (50 matches)" "$wx_ms" "$ow_ms" "$iters"

  # Test 4: Large PATH
  iters=500
  wx_ms=$(PATH="$LARGEPATH" benchmark $iters "$WHICHX" testcmd)
  ow_ms=$(PATH="$LARGEPATH" benchmark $iters "$OLDWHICH" testcmd)
  result "Large PATH (50 dirs)" "$wx_ms" "$ow_ms" "$iters"

  # Test 5: Not found
  iters=1000
  wx_ms=$(benchmark $iters "$WHICHX" nonexistent_command_xyz)
  ow_ms=$(benchmark $iters "$OLDWHICH" nonexistent_command_xyz)
  result "Not found" "$wx_ms" "$ow_ms" "$iters"

  # Test 6: Quiet mode (whichx only, compare -s vs normal)
  iters=1000
  wx_ms=$(benchmark $iters "$WHICHX" -q ls)
  ow_ms=$(benchmark $iters "$WHICHX" ls)
  result "-q vs normal (whichx)" "$wx_ms" "$ow_ms" "$iters"

  echo "#"
  echo "# Notes:"
  echo "#   - old.which runs under /bin/sh (likely dash)"
  echo "#   - whichx is bash 4.4+ with more features"
  echo "#   - Performance difference is negligible for real-world use"
}

setup
run_benchmarks
