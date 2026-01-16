#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# CI benchmark: compare which vs legacy-which/which.debianutils
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
WHICH="$SCRIPT_DIR/../which"
LEGACY="$SCRIPT_DIR/../legacy-which/which.debianutils"

if [[ ! -x "$LEGACY" ]]; then
  echo "Warning: $LEGACY not executable, skipping comparison" >&2
  LEGACY=""
fi

benchmark() {
  local -i iters=$1; shift
  local start end
  start=$(date +%s%N)
  for ((i=0; i<iters; i++)); do "$@" >/dev/null 2>&1 || true; done
  end=$(date +%s%N)
  echo $(( (end - start) / 1000000 ))
}

echo "# CI Benchmark: which vs which.debianutils"
if [[ -n "$LEGACY" ]]; then
  printf '%-25s %12s %12s\n' "Test" "which(ms)" "debian(ms)"
else
  printf '%-25s %12s\n' "Test" "which(ms)"
fi
echo "# $(printf '%.0s-' {1..51})"

iters=500

wx=$(benchmark $iters "$WHICH" ls)
if [[ -n "$LEGACY" ]]; then
  deb=$(benchmark $iters "$LEGACY" ls)
  printf '%-25s %12d %12d\n' "Single lookup (${iters}x)" "$wx" "$deb"
else
  printf '%-25s %12d\n' "Single lookup (${iters}x)" "$wx"
fi

wx=$(benchmark $iters "$WHICH" -q ls)
if [[ -n "$LEGACY" ]]; then
  deb=$(benchmark $iters "$LEGACY" -s ls)
  printf '%-25s %12d %12d\n' "Silent mode (${iters}x)" "$wx" "$deb"
else
  printf '%-25s %12d\n' "Silent mode (${iters}x)" "$wx"
fi

wx=$(benchmark $iters "$WHICH" nonexistent_cmd)
if [[ -n "$LEGACY" ]]; then
  deb=$(benchmark $iters "$LEGACY" nonexistent_cmd)
  printf '%-25s %12d %12d\n' "Not found (${iters}x)" "$wx" "$deb"
else
  printf '%-25s %12d\n' "Not found (${iters}x)" "$wx"
fi

echo "# Benchmark complete"
