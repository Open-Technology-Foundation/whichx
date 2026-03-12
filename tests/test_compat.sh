#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Compatibility: which vs legacy Debian which implementations
set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
WHICH="$SCRIPT_DIR/../which"
LEGACY_CORE22="$SCRIPT_DIR/../legacy-which/which.debianutils-core22"
LEGACY_DEBUTIL="$SCRIPT_DIR/../legacy-which/which.debianutils"

HAS_CORE22=0; [[ -f "$LEGACY_CORE22" ]] && HAS_CORE22=1
HAS_DEBUTIL=0; [[ -f "$LEGACY_DEBUTIL" ]] && HAS_DEBUTIL=1

if ((! HAS_CORE22 && ! HAS_DEBUTIL)); then
  echo "Bail out! No legacy which found"
  exit 1
fi

declare -i tests=0 passed=0 failed=0

# TAP-style output
ok()     { ((++tests)); ((++passed)); printf 'ok %d - %s\n' "$tests" "$1"; }
not_ok() { ((++tests)); ((++failed)); printf 'not ok %d - %s\n' "$tests" "$1"; }
skip()   { ((++tests)); ((++passed)); printf 'ok %d - # SKIP %s\n' "$tests" "$1"; }

assert_exit() {
  local -i expected=$1 actual=$2
  local desc=$3
  if [[ $actual -eq $expected ]]; then ok "$desc"; else not_ok "$desc (expected $expected, got $actual)"; fi
}

assert_rc_match() {
  local desc=$1
  local -i rc1=$2 rc2=$3
  if (( rc1 == rc2 )); then ok "$desc"; else not_ok "$desc (which=$rc1, legacy=$rc2)"; fi
}

assert_out_match() {
  local desc=$1 out1=$2 out2=$3
  if [[ "$out1" == "$out2" ]]; then ok "$desc"; else not_ok "$desc (which='$out1', legacy='$out2')"; fi
}

# Setup test fixtures
setup() {
  TESTDIR=$(mktemp -d)
  mkdir -p "$TESTDIR"/{bin1,bin2,bin3}

  printf '#!/bin/sh\necho test' > "$TESTDIR/bin1/testcmd"
  chmod +x "$TESTDIR/bin1/testcmd"
  cp "$TESTDIR/bin1/testcmd" "$TESTDIR/bin2/testcmd"

  # Non-executable file
  touch "$TESTDIR/bin1/noexec"

  # Directory with same name
  mkdir "$TESTDIR/bin1/testdir"

  # Special character command
  printf '#!/bin/sh\necho special' > "$TESTDIR/bin1/test+cmd"
  chmod +x "$TESTDIR/bin1/test+cmd"

  # Hyphen-prefixed command
  printf '#!/bin/sh\necho hyphen' > "$TESTDIR/bin1/-hyphen"
  chmod +x "$TESTDIR/bin1/-hyphen"

  # Executable for cwd test
  printf '#!/bin/sh\necho cwd' > "$TESTDIR/cwdcmd"
  chmod +x "$TESTDIR/cwdcmd"

  TESTPATH="$TESTDIR/bin1:$TESTDIR/bin2:$TESTDIR/bin3:/usr/bin:/bin"
}

teardown() {
  rm -rf "$TESTDIR"
}

trap teardown EXIT
setup

echo "# which compatibility test suite"

# ============================================================
# Part 1: vs core22 (basic which with -a only)
# ============================================================

run_core22_tests() {
  if ((!HAS_CORE22)); then
    local -i i
    for ((i = 1; i <= 38; i++)); do
      skip "core22 not available"
    done
    return
  fi

  echo "# Part 1: vs which.debianutils-core22"

  local w_out w_rc l_out l_rc

  # --- BASIC SEARCH ---
  echo "# Basic search"

  # 1. Find ls
  w_out=$("$WHICH" ls 2>/dev/null); w_rc=$?
  l_out=$(/bin/sh "$LEGACY_CORE22" ls 2>/dev/null); l_rc=$?
  assert_rc_match "core22: find ls — exit code" $w_rc $l_rc
  assert_out_match "core22: find ls — output" "$w_out" "$l_out"

  # 2. Nonexistent command
  w_out=$("$WHICH" nonexistent_cmd_xyz 2>/dev/null); w_rc=$?
  l_out=$(/bin/sh "$LEGACY_CORE22" nonexistent_cmd_xyz 2>/dev/null); l_rc=$?
  assert_rc_match "core22: nonexistent — exit code" $w_rc $l_rc
  assert_out_match "core22: nonexistent — output" "$w_out" "$l_out"

  # 3. No arguments
  w_out=$("$WHICH" 2>/dev/null); w_rc=$?
  l_out=$(/bin/sh "$LEGACY_CORE22" 2>/dev/null); l_rc=$?
  assert_rc_match "core22: no arguments — exit code" $w_rc $l_rc

  # --- MULTIPLE TARGETS ---
  echo "# Multiple targets"

  # 4. Multiple existing (ls cat)
  w_out=$("$WHICH" ls cat 2>/dev/null); w_rc=$?
  l_out=$(/bin/sh "$LEGACY_CORE22" ls cat 2>/dev/null); l_rc=$?
  assert_rc_match "core22: multiple existing — exit code" $w_rc $l_rc
  assert_out_match "core22: multiple existing — output" "$w_out" "$l_out"

  # 5. Mixed (ls nonexistent cat)
  w_out=$("$WHICH" ls nonexistent_xyz cat 2>/dev/null); w_rc=$?
  l_out=$(/bin/sh "$LEGACY_CORE22" ls nonexistent_xyz cat 2>/dev/null); l_rc=$?
  assert_rc_match "core22: mixed targets — exit code" $w_rc $l_rc

  # 6. Duplicate target (ls ls)
  w_out=$("$WHICH" ls ls 2>/dev/null); w_rc=$?
  l_out=$(/bin/sh "$LEGACY_CORE22" ls ls 2>/dev/null); l_rc=$?
  assert_rc_match "core22: duplicate target — exit code" $w_rc $l_rc
  assert_out_match "core22: duplicate target — output" "$w_out" "$l_out"

  # --- -a FLAG ---
  echo "# -a flag"

  # 7. -a testcmd (in 2 dirs)
  w_out=$(PATH="$TESTPATH" "$WHICH" -a testcmd 2>/dev/null); w_rc=$?
  l_out=$(PATH="$TESTPATH" /bin/sh "$LEGACY_CORE22" -a testcmd 2>/dev/null); l_rc=$?
  assert_rc_match "core22: -a multiple matches — exit code" $w_rc $l_rc
  assert_out_match "core22: -a multiple matches — output" "$w_out" "$l_out"

  # 8. -a output order (bin1 before bin2)
  local w_first w_second l_first l_second
  w_first=$(echo "$w_out" | head -n1)
  l_first=$(echo "$l_out" | head -n1)
  assert_out_match "core22: -a order first line" "$w_first" "$l_first"
  w_second=$(echo "$w_out" | sed -n '2p')
  l_second=$(echo "$l_out" | sed -n '2p')
  assert_out_match "core22: -a order second line" "$w_second" "$l_second"

  # 9. -a with single match only
  w_out=$(PATH="$TESTDIR/bin1" "$WHICH" -a testcmd 2>/dev/null); w_rc=$?
  l_out=$(PATH="$TESTDIR/bin1" /bin/sh "$LEGACY_CORE22" -a testcmd 2>/dev/null); l_rc=$?
  assert_rc_match "core22: -a single match — exit code" $w_rc $l_rc
  assert_out_match "core22: -a single match — output" "$w_out" "$l_out"

  # --- PATH HANDLING ---
  echo "# PATH handling"

  # 10. Leading colon (PATH=":...")
  pushd "$TESTDIR" >/dev/null || return 1
  w_out=$(PATH=":/usr/bin:$TESTDIR/bin1" "$WHICH" cwdcmd 2>/dev/null); w_rc=$?
  l_out=$(PATH=":/usr/bin:$TESTDIR/bin1" /bin/sh "$LEGACY_CORE22" cwdcmd 2>/dev/null); l_rc=$?
  assert_rc_match "core22: leading colon — exit code" $w_rc $l_rc
  assert_out_match "core22: leading colon — output" "$w_out" "$l_out"
  popd >/dev/null || return 1

  # 11. Trailing colon (PATH="...:")
  pushd "$TESTDIR" >/dev/null || return 1
  w_out=$(PATH="/usr/bin:$TESTDIR/bin1:" "$WHICH" cwdcmd 2>/dev/null); w_rc=$?
  l_out=$(PATH="/usr/bin:$TESTDIR/bin1:" /bin/sh "$LEGACY_CORE22" cwdcmd 2>/dev/null); l_rc=$?
  assert_rc_match "core22: trailing colon — exit code" $w_rc $l_rc
  assert_out_match "core22: trailing colon — output" "$w_out" "$l_out"
  popd >/dev/null || return 1

  # 12. Double colon (PATH="...::...")
  pushd "$TESTDIR" >/dev/null || return 1
  w_out=$(PATH="/usr/bin:$TESTDIR/bin1::$TESTDIR/bin2" "$WHICH" cwdcmd 2>/dev/null); w_rc=$?
  l_out=$(PATH="/usr/bin:$TESTDIR/bin1::$TESTDIR/bin2" /bin/sh "$LEGACY_CORE22" cwdcmd 2>/dev/null); l_rc=$?
  assert_rc_match "core22: double colon — exit code" $w_rc $l_rc
  assert_out_match "core22: double colon — output" "$w_out" "$l_out"
  popd >/dev/null || return 1

  # 13. Empty PATH
  w_out=$(PATH="" /bin/bash "$WHICH" ls 2>/dev/null); w_rc=$?
  l_out=$(PATH="" /bin/sh "$LEGACY_CORE22" ls 2>/dev/null); l_rc=$?
  assert_rc_match "core22: empty PATH — exit code" $w_rc $l_rc

  # 14. Nonexistent dir in PATH
  w_out=$(PATH="/nonexistent:/usr/bin:$TESTDIR/bin1" "$WHICH" testcmd 2>/dev/null); w_rc=$?
  l_out=$(PATH="/nonexistent:/usr/bin:$TESTDIR/bin1" /bin/sh "$LEGACY_CORE22" testcmd 2>/dev/null); l_rc=$?
  assert_rc_match "core22: nonexistent dir in PATH — exit code" $w_rc $l_rc
  assert_out_match "core22: nonexistent dir in PATH — output" "$w_out" "$l_out"

  # 15. PATH with explicit dot
  pushd "$TESTDIR" >/dev/null || return 1
  w_out=$(PATH=".:/usr/bin" "$WHICH" cwdcmd 2>/dev/null); w_rc=$?
  l_out=$(PATH=".:/usr/bin" /bin/sh "$LEGACY_CORE22" cwdcmd 2>/dev/null); l_rc=$?
  assert_rc_match "core22: explicit dot — exit code" $w_rc $l_rc
  assert_out_match "core22: explicit dot — output" "$w_out" "$l_out"
  popd >/dev/null || return 1

  # --- SLASH PATHS ---
  echo "# Slash paths"

  # 16. Absolute path /usr/bin/ls
  w_out=$("$WHICH" /usr/bin/ls 2>/dev/null); w_rc=$?
  l_out=$(/bin/sh "$LEGACY_CORE22" /usr/bin/ls 2>/dev/null); l_rc=$?
  assert_rc_match "core22: absolute path — exit code" $w_rc $l_rc
  assert_out_match "core22: absolute path — output" "$w_out" "$l_out"

  # 17. Relative path ./cwdcmd
  pushd "$TESTDIR" >/dev/null || return 1
  w_out=$("$WHICH" ./cwdcmd 2>/dev/null); w_rc=$?
  l_out=$(/bin/sh "$LEGACY_CORE22" ./cwdcmd 2>/dev/null); l_rc=$?
  assert_rc_match "core22: relative path — exit code" $w_rc $l_rc
  assert_out_match "core22: relative path — output" "$w_out" "$l_out"
  popd >/dev/null || return 1

  # --- EDGE CASES ---
  echo "# Edge cases"

  # 18. Non-executable file
  w_out=$(PATH="$TESTPATH" "$WHICH" noexec 2>/dev/null); w_rc=$?
  l_out=$(PATH="$TESTPATH" /bin/sh "$LEGACY_CORE22" noexec 2>/dev/null); l_rc=$?
  assert_rc_match "core22: non-executable — exit code" $w_rc $l_rc

  # 19. Directory same name as target
  w_out=$(PATH="$TESTPATH" "$WHICH" testdir 2>/dev/null); w_rc=$?
  l_out=$(PATH="$TESTPATH" /bin/sh "$LEGACY_CORE22" testdir 2>/dev/null); l_rc=$?
  assert_rc_match "core22: directory as target — exit code" $w_rc $l_rc
}

# ============================================================
# Part 2: vs debianutils (has -a and -s)
# ============================================================

run_debutil_tests() {
  if ((!HAS_DEBUTIL)); then
    local -i i
    for ((i = 1; i <= 14; i++)); do
      skip "debianutils not available"
    done
    return
  fi

  echo "# Part 2: vs which.debianutils"

  local w_out w_rc l_out l_rc

  # --- SILENT MODE ---
  echo "# Silent mode"

  # 1. -s existing command
  w_out=$(PATH="$TESTPATH" "$WHICH" -s testcmd 2>/dev/null); w_rc=$?
  l_out=$(PATH="$TESTPATH" /bin/sh "$LEGACY_DEBUTIL" -s testcmd 2>/dev/null); l_rc=$?
  assert_rc_match "debutil: -s existing — exit code" $w_rc $l_rc
  assert_out_match "debutil: -s existing — output" "$w_out" "$l_out"

  # 2. -s nonexistent command
  w_out=$(PATH="$TESTPATH" "$WHICH" -s nonexistent 2>/dev/null); w_rc=$?
  l_out=$(PATH="$TESTPATH" /bin/sh "$LEGACY_DEBUTIL" -s nonexistent 2>/dev/null); l_rc=$?
  assert_rc_match "debutil: -s nonexistent — exit code" $w_rc $l_rc
  assert_out_match "debutil: -s nonexistent — output" "$w_out" "$l_out"

  # 3. -a existing (both show results)
  w_out=$(PATH="$TESTPATH" "$WHICH" -a testcmd 2>/dev/null); w_rc=$?
  l_out=$(PATH="$TESTPATH" /bin/sh "$LEGACY_DEBUTIL" -a testcmd 2>/dev/null); l_rc=$?
  assert_rc_match "debutil: -a existing — exit code" $w_rc $l_rc
  assert_out_match "debutil: -a existing — output" "$w_out" "$l_out"

  # 4. -a output order matches
  local w_first l_first
  w_first=$(echo "$w_out" | head -n1)
  l_first=$(echo "$l_out" | head -n1)
  assert_out_match "debutil: -a order first line" "$w_first" "$l_first"

  # --- SHARED BASICS (verify debianutils too) ---
  echo "# Shared basics"

  # 5. Find ls
  w_out=$("$WHICH" ls 2>/dev/null); w_rc=$?
  l_out=$(/bin/sh "$LEGACY_DEBUTIL" ls 2>/dev/null); l_rc=$?
  assert_rc_match "debutil: find ls — exit code" $w_rc $l_rc
  assert_out_match "debutil: find ls — output" "$w_out" "$l_out"

  # 6. No arguments
  w_out=$("$WHICH" 2>/dev/null); w_rc=$?
  l_out=$(/bin/sh "$LEGACY_DEBUTIL" 2>/dev/null); l_rc=$?
  assert_rc_match "debutil: no arguments — exit code" $w_rc $l_rc

  # 7. Nonexistent
  w_out=$("$WHICH" nonexistent_cmd_xyz 2>/dev/null); w_rc=$?
  l_out=$(/bin/sh "$LEGACY_DEBUTIL" nonexistent_cmd_xyz 2>/dev/null); l_rc=$?
  assert_rc_match "debutil: nonexistent — exit code" $w_rc $l_rc
  assert_out_match "debutil: nonexistent — output" "$w_out" "$l_out"
}

# === RUN ===

run_core22_tests
run_debutil_tests

# --- SUMMARY ---
echo
printf '1..%d\n' "$tests"
echo "# $tests tests, $passed passed, $failed failed"

exit $failed
#fin
