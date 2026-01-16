#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Comprehensive test suite for which
set -uo pipefail  # Note: no -e, we handle exit codes manually

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
WHICH="$SCRIPT_DIR/../which"

declare -i tests=0 passed=0 failed=0

# TAP-style output
ok()     { ((++tests)); ((++passed)); printf 'ok %d - %s\n' "$tests" "$1"; }
not_ok() { ((++tests)); ((++failed)); printf 'not ok %d - %s\n' "$tests" "$1"; }

# Assertions
assert_exit() {
  local -i expected=$1 actual=$2
  local desc=$3
  if [[ $actual -eq $expected ]]; then ok "$desc"; else not_ok "$desc (expected $expected, got $actual)"; fi
}

assert_output() {
  local expected=$1 actual=$2 desc=$3
  if [[ "$actual" == "$expected" ]]; then ok "$desc"; else not_ok "$desc (expected '$expected', got '$actual')"; fi
}

assert_contains() {
  local needle=$1 haystack=$2 desc=$3
  if [[ "$haystack" == *"$needle"* ]]; then ok "$desc"; else not_ok "$desc (missing '$needle')"; fi
}

assert_empty() {
  local actual=$1 desc=$2
  if [[ -z "$actual" ]]; then ok "$desc"; else not_ok "$desc (expected empty, got '$actual')"; fi
}

assert_not_empty() {
  local actual=$1 desc=$2
  if [[ -n "$actual" ]]; then ok "$desc"; else not_ok "$desc (expected non-empty)"; fi
}

# Setup test fixtures
setup() {
  TESTDIR=$(mktemp -d)
  mkdir -p "$TESTDIR"/{bin1,bin2,bin3}

  # Test executable in multiple dirs
  printf '#!/bin/sh\necho test' > "$TESTDIR/bin1/testcmd"
  chmod +x "$TESTDIR/bin1/testcmd"
  cp "$TESTDIR/bin1/testcmd" "$TESTDIR/bin2/testcmd"

  # Symlink for -c testing
  ln -s "$TESTDIR/bin1/testcmd" "$TESTDIR/bin1/symcmd"

  # Multi-level symlink
  ln -s "$TESTDIR/bin1/symcmd" "$TESTDIR/bin1/sym2cmd"

  # Broken symlink
  ln -s "$TESTDIR/nonexistent" "$TESTDIR/bin1/brokensym"

  # Non-executable file
  touch "$TESTDIR/bin1/noexec"

  # Directory with same name (shouldn't match)
  mkdir "$TESTDIR/bin1/testdir"

  # Executable for cwd test
  printf '#!/bin/sh\necho cwd' > "$TESTDIR/cwdcmd"
  chmod +x "$TESTDIR/cwdcmd"

  # Command starting with hyphen
  printf '#!/bin/sh\necho hyphen' > "$TESTDIR/bin1/-hyphen"
  chmod +x "$TESTDIR/bin1/-hyphen"

  TESTPATH="$TESTDIR/bin1:$TESTDIR/bin2:$TESTDIR/bin3:/usr/bin:/bin"
}

teardown() {
  rm -rf "$TESTDIR"
}

trap teardown EXIT

# === TESTS ===

run_tests() {
  echo "# which test suite"

  # --- BASIC OPERATIONS ---
  echo "# Basic operations"

  local out rc

  # Find existing command
  out=$("$WHICH" ls 2>&1); rc=$?
  assert_exit 0 $rc "basic: find ls"
  assert_contains "/ls" "$out" "basic: output contains /ls"

  # Find non-existent command
  out=$("$WHICH" nonexistent_cmd_xyz 2>&1); rc=$?
  assert_exit 1 $rc "basic: nonexistent returns 1"

  # Multiple commands (all exist)
  out=$("$WHICH" ls cat 2>&1); rc=$?
  assert_exit 0 $rc "basic: multiple existing"

  # Multiple commands (mixed)
  out=$("$WHICH" ls nonexistent_xyz cat 2>&1); rc=$?
  assert_exit 1 $rc "basic: mixed returns 1"

  # Multiple commands (none exist)
  out=$("$WHICH" nope1 nope2 nope3 2>&1); rc=$?
  assert_exit 1 $rc "basic: all nonexistent returns 1"

  # --- OPTIONS ---
  echo "# Options"

  # -a / --all
  out=$(PATH="$TESTPATH" "$WHICH" -a testcmd 2>&1); rc=$?
  assert_exit 0 $rc "opt: -a finds command"
  local lines
  lines=$(echo "$out" | wc -l)
  if [[ $lines -ge 2 ]]; then ok "opt: -a returns multiple matches"; else not_ok "opt: -a returns multiple matches (got $lines)"; fi

  out=$(PATH="$TESTPATH" "$WHICH" --all testcmd 2>&1); rc=$?
  assert_exit 0 $rc "opt: --all works"

  # -c / --canonical
  out=$(PATH="$TESTPATH" "$WHICH" -c symcmd 2>&1); rc=$?
  assert_exit 0 $rc "opt: -c finds symlink"
  assert_contains "testcmd" "$out" "opt: -c resolves to real path"

  out=$(PATH="$TESTPATH" "$WHICH" --canonical symcmd 2>&1); rc=$?
  assert_exit 0 $rc "opt: --canonical works"

  # -q / --quiet
  out=$(PATH="$TESTPATH" "$WHICH" -q testcmd 2>&1); rc=$?
  assert_exit 0 $rc "opt: -q returns 0 when found"
  assert_empty "$out" "opt: -q produces no output"

  out=$(PATH="$TESTPATH" "$WHICH" -q nonexistent 2>&1); rc=$?
  assert_exit 1 $rc "opt: -q returns 1 when not found"

  out=$(PATH="$TESTPATH" "$WHICH" --quiet testcmd 2>&1); rc=$?
  assert_empty "$out" "opt: --quiet produces no output"

  # -s / --silent (alias)
  out=$(PATH="$TESTPATH" "$WHICH" -s testcmd 2>&1); rc=$?
  assert_exit 0 $rc "opt: -s works"
  assert_empty "$out" "opt: -s produces no output"

  out=$(PATH="$TESTPATH" "$WHICH" --silent testcmd 2>&1); rc=$?
  assert_empty "$out" "opt: --silent works"

  # -V / --version
  out=$("$WHICH" -V 2>&1); rc=$?
  assert_exit 0 $rc "opt: -V returns 0"
  assert_contains "which" "$out" "opt: -V shows name"
  assert_contains "2.0" "$out" "opt: -V shows version"

  out=$("$WHICH" --version 2>&1); rc=$?
  assert_exit 0 $rc "opt: --version works"

  # -h / --help
  out=$("$WHICH" -h 2>&1); rc=$?
  assert_exit 0 $rc "opt: -h returns 0"
  assert_contains "Usage:" "$out" "opt: -h shows usage"

  out=$("$WHICH" --help 2>&1); rc=$?
  assert_exit 0 $rc "opt: --help works"

  # Combined options
  out=$(PATH="$TESTPATH" "$WHICH" -ac symcmd 2>&1); rc=$?
  assert_exit 0 $rc "opt: -ac combined works"

  out=$(PATH="$TESTPATH" "$WHICH" -qa testcmd 2>&1); rc=$?
  assert_exit 0 $rc "opt: -qa combined works"
  assert_empty "$out" "opt: -qa still quiet"

  out=$(PATH="$TESTPATH" "$WHICH" -aqs testcmd 2>&1); rc=$?
  assert_exit 0 $rc "opt: -aqs triple combined"

  # --- EXIT CODES ---
  echo "# Exit codes"

  "$WHICH" ls >/dev/null 2>&1; rc=$?
  assert_exit 0 $rc "exit: 0 when found"

  "$WHICH" nonexistent_xyz >/dev/null 2>&1; rc=$?
  assert_exit 1 $rc "exit: 1 when not found"

  "$WHICH" 2>/dev/null; rc=$?
  assert_exit 2 $rc "exit: 2 when no args"

  "$WHICH" -z 2>/dev/null; rc=$?
  assert_exit 22 $rc "exit: 22 for invalid option"

  "$WHICH" --badopt 2>/dev/null; rc=$?
  assert_exit 22 $rc "exit: 22 for invalid long option"

  # --- PATH HANDLING ---
  echo "# PATH handling"

  # Leading colon (cwd first)
  pushd "$TESTDIR" >/dev/null || return 1
  out=$(PATH=":$TESTDIR/bin1" "$WHICH" cwdcmd 2>&1); rc=$?
  assert_exit 0 $rc "path: leading colon finds cwd"
  popd >/dev/null || return 1

  # Trailing colon (cwd last)
  pushd "$TESTDIR" >/dev/null || return 1
  out=$(PATH="$TESTDIR/bin1:" "$WHICH" cwdcmd 2>&1); rc=$?
  assert_exit 0 $rc "path: trailing colon finds cwd"
  popd >/dev/null || return 1

  # Double colon (cwd in middle)
  pushd "$TESTDIR" >/dev/null || return 1
  out=$(PATH="$TESTDIR/bin1::$TESTDIR/bin2" "$WHICH" cwdcmd 2>&1); rc=$?
  assert_exit 0 $rc "path: double colon finds cwd"
  popd >/dev/null || return 1

  # Empty PATH
  out=$(PATH="" "$WHICH" ls 2>&1); rc=$?
  assert_exit 1 $rc "path: empty PATH returns 1"

  # PATH with non-existent directories
  out=$(PATH="/nonexistent:$TESTDIR/bin1" "$WHICH" testcmd 2>&1); rc=$?
  assert_exit 0 $rc "path: skips non-existent dirs"

  # Single dot in PATH
  pushd "$TESTDIR" >/dev/null || return 1
  out=$(PATH="." "$WHICH" cwdcmd 2>&1); rc=$?
  assert_exit 0 $rc "path: explicit dot works"
  popd >/dev/null || return 1

  # --- INPUT HANDLING ---
  echo "# Input handling"

  # Absolute path
  out=$("$WHICH" /usr/bin/ls 2>&1); rc=$?
  assert_exit 0 $rc "input: absolute path"
  assert_output "/usr/bin/ls" "$out" "input: absolute path output"

  # Relative path
  pushd "$TESTDIR" >/dev/null || return 1
  out=$("$WHICH" ./cwdcmd 2>&1); rc=$?
  assert_exit 0 $rc "input: relative path"
  popd >/dev/null || return 1

  # -- separator
  out=$(PATH="$TESTPATH" "$WHICH" -- testcmd 2>&1); rc=$?
  assert_exit 0 $rc "input: -- separator"

  # Command starting with hyphen
  out=$(PATH="$TESTPATH" "$WHICH" -- -hyphen 2>&1); rc=$?
  assert_exit 0 $rc "input: hyphen command via --"

  # --- EDGE CASES ---
  echo "# Edge cases"

  # Non-executable not matched
  out=$(PATH="$TESTPATH" "$WHICH" noexec 2>&1); rc=$?
  assert_exit 1 $rc "edge: non-executable not matched"

  # Directory not matched
  out=$(PATH="$TESTPATH" "$WHICH" testdir 2>&1); rc=$?
  assert_exit 1 $rc "edge: directory not matched"

  # Multi-level symlink resolution
  out=$(PATH="$TESTPATH" "$WHICH" -c sym2cmd 2>&1); rc=$?
  assert_exit 0 $rc "edge: multi-level symlink resolved"
  assert_contains "testcmd" "$out" "edge: resolves to final target"

  # Broken symlink with -c
  out=$(PATH="$TESTPATH" "$WHICH" brokensym 2>&1); rc=$?
  assert_exit 1 $rc "edge: broken symlink not found (not executable)"

  # --- SOURCED MODE ---
  echo "# Sourced mode"

  # Source creates which function
  out=$(bash -c "source '$WHICH' && type which 2>&1"); rc=$?
  assert_exit 0 $rc "sourced: creates which function"
  assert_contains "function" "$out" "sourced: type reports function"

  # Function finds commands
  out=$(bash -c "source '$WHICH' && which ls 2>&1"); rc=$?
  assert_exit 0 $rc "sourced: finds ls"
  assert_contains "/ls" "$out" "sourced: outputs path"

  # Options work: -a
  out=$(bash -c "source '$WHICH' && PATH='$TESTPATH' which -a testcmd 2>&1"); rc=$?
  assert_exit 0 $rc "sourced: -a works"

  # Options work: -q
  out=$(bash -c "source '$WHICH' && which -q ls 2>&1"); rc=$?
  assert_exit 0 $rc "sourced: -q works"
  assert_empty "$out" "sourced: -q no output"

  # Options work: -V
  out=$(bash -c "source '$WHICH' && which -V 2>&1"); rc=$?
  assert_exit 0 $rc "sourced: -V works"
  assert_contains "2.0" "$out" "sourced: -V shows version"

  # Options work: -h (brief help when sourced)
  out=$(bash -c "source '$WHICH' && which -h 2>&1"); rc=$?
  assert_exit 0 $rc "sourced: -h works"
  assert_contains "Usage:" "$out" "sourced: -h shows usage"

  # Strict mode isolation: errexit not set
  out=$(bash -c "source '$WHICH'; [[ \$- == *e* ]] && echo FAIL || echo OK"); rc=$?
  assert_output "OK" "$out" "sourced: errexit not set in parent"

  # Strict mode isolation: nounset not set
  out=$(bash -c "source '$WHICH'; [[ \$- == *u* ]] && echo FAIL || echo OK"); rc=$?
  assert_output "OK" "$out" "sourced: nounset not set in parent"

  # Strict mode isolation: pipefail not set
  out=$(bash -c "source '$WHICH'; shopt -q -o pipefail && echo FAIL || echo OK"); rc=$?
  assert_output "OK" "$out" "sourced: pipefail not set in parent"

  # Function exported to subshells
  out=$(bash -c "source '$WHICH' && bash -c 'type which' 2>&1"); rc=$?
  assert_exit 0 $rc "sourced: function exported"
  assert_contains "function" "$out" "sourced: subshell sees function"

  # Return vs exit: error doesn't kill shell
  out=$(bash -c "source '$WHICH'; which nonexistent_xyz 2>/dev/null; echo ALIVE"); rc=$?
  assert_contains "ALIVE" "$out" "sourced: error returns, doesn't exit"

  # Return vs exit: no args doesn't kill shell
  out=$(bash -c "source '$WHICH'; which 2>/dev/null; echo ALIVE"); rc=$?
  assert_contains "ALIVE" "$out" "sourced: no args returns, doesn't exit"

  # --- SUMMARY ---
  echo
  printf '1..%d\n' "$tests"
  echo "# $tests tests, $passed passed, $failed failed"

  return $failed
}

setup
run_tests
