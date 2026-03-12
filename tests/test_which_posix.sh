#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later
# POSIX-compatible test suite for which.sh
# Runs under /bin/sh — no bashisms

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
WHICH="$SCRIPT_DIR/../which.sh"

tests=0
passed=0
failed=0

ok() {
  tests=$((tests + 1))
  passed=$((passed + 1))
  printf 'ok %d - %s\n' "$tests" "$1"
}

not_ok() {
  tests=$((tests + 1))
  failed=$((failed + 1))
  printf 'not ok %d - %s\n' "$tests" "$1"
}

assert_exit() {
  expected=$1 actual=$2 desc=$3
  if [ "$actual" -eq "$expected" ]; then
    ok "$desc"
  else
    not_ok "$desc (expected $expected, got $actual)"
  fi
}

assert_output() {
  expected=$1 actual=$2 desc=$3
  if [ "$actual" = "$expected" ]; then
    ok "$desc"
  else
    not_ok "$desc (expected '$expected', got '$actual')"
  fi
}

assert_contains() {
  needle=$1 haystack=$2 desc=$3
  case "$haystack" in
    *"$needle"*) ok "$desc" ;;
    *) not_ok "$desc (missing '$needle')" ;;
  esac
}

assert_empty() {
  actual=$1 desc=$2
  if [ -z "$actual" ]; then
    ok "$desc"
  else
    not_ok "$desc (expected empty, got '$actual')"
  fi
}

assert_not_empty() {
  actual=$1 desc=$2
  if [ -n "$actual" ]; then
    ok "$desc"
  else
    not_ok "$desc (expected non-empty)"
  fi
}

# Setup test fixtures
setup() {
  TESTDIR=$(mktemp -d)
  mkdir -p "$TESTDIR/bin1" "$TESTDIR/bin2" "$TESTDIR/bin3"

  # Test executable in multiple dirs
  printf '#!/bin/sh\necho test\n' > "$TESTDIR/bin1/testcmd"
  chmod +x "$TESTDIR/bin1/testcmd"
  cp "$TESTDIR/bin1/testcmd" "$TESTDIR/bin2/testcmd"

  # Symlink for -c testing
  ln -s "$TESTDIR/bin1/testcmd" "$TESTDIR/bin1/symcmd"

  # Multi-level symlink
  ln -s "$TESTDIR/bin1/symcmd" "$TESTDIR/bin1/sym2cmd"

  # Non-executable file
  touch "$TESTDIR/bin1/noexec"

  # Directory with same name (shouldn't match)
  mkdir "$TESTDIR/bin1/testdir"

  # Executable for cwd test
  printf '#!/bin/sh\necho cwd\n' > "$TESTDIR/cwdcmd"
  chmod +x "$TESTDIR/cwdcmd"

  # Command starting with hyphen
  printf '#!/bin/sh\necho hyphen\n' > "$TESTDIR/bin1/-hyphen"
  chmod +x "$TESTDIR/bin1/-hyphen"

  TESTPATH="$TESTDIR/bin1:$TESTDIR/bin2:$TESTDIR/bin3:/usr/bin:/bin"
}

teardown() {
  rm -rf "$TESTDIR"
}

trap teardown EXIT

run_tests() {
  echo "# which.sh (POSIX) test suite"

  # --- BASIC OPERATIONS ---
  echo "# Basic operations"

  out=$("$WHICH" ls 2>&1); rc=$?
  assert_exit 0 "$rc" "basic: find ls"
  assert_contains "/ls" "$out" "basic: output contains /ls"

  out=$("$WHICH" nonexistent_cmd_xyz 2>&1); rc=$?
  assert_exit 1 "$rc" "basic: nonexistent returns 1"

  out=$("$WHICH" ls cat 2>&1); rc=$?
  assert_exit 0 "$rc" "basic: multiple existing"

  out=$("$WHICH" ls nonexistent_xyz cat 2>&1); rc=$?
  assert_exit 1 "$rc" "basic: mixed returns 1"

  out=$("$WHICH" nope1 nope2 nope3 2>&1); rc=$?
  assert_exit 1 "$rc" "basic: all nonexistent returns 1"

  # --- OPTIONS ---
  echo "# Options"

  # -a / --all
  out=$(PATH="$TESTPATH" "$WHICH" -a testcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "opt: -a finds command"
  lines=$(printf '%s\n' "$out" | wc -l)
  if [ "$lines" -ge 2 ]; then
    ok "opt: -a returns multiple matches"
  else
    not_ok "opt: -a returns multiple matches (got $lines)"
  fi

  out=$(PATH="$TESTPATH" "$WHICH" --all testcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "opt: --all works"

  # -c / --canonical
  out=$(PATH="$TESTPATH" "$WHICH" -c symcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "opt: -c finds symlink"
  assert_contains "testcmd" "$out" "opt: -c resolves to real path"

  out=$(PATH="$TESTPATH" "$WHICH" --canonical symcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "opt: --canonical works"

  # -s returns correct exit codes
  out=$(PATH="$TESTPATH" "$WHICH" -s testcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "opt: -s returns 0 when found"
  assert_empty "$out" "opt: -s produces no output (found)"

  out=$(PATH="$TESTPATH" "$WHICH" -s nonexistent 2>&1); rc=$?
  assert_exit 1 "$rc" "opt: -s returns 1 when not found"

  out=$(PATH="$TESTPATH" "$WHICH" --silent testcmd 2>&1); rc=$?
  assert_empty "$out" "opt: --silent produces no output"

  # -q is not a valid option (removed in 2.0)
  out=$(PATH="$TESTPATH" "$WHICH" -q testcmd 2>&1); rc=$?
  assert_exit 2 "$rc" "opt: -q is invalid option"

  # -V / --version
  out=$("$WHICH" -V 2>&1); rc=$?
  assert_exit 0 "$rc" "opt: -V returns 0"
  assert_contains "which" "$out" "opt: -V shows name"
  assert_contains "2.0" "$out" "opt: -V shows version"

  out=$("$WHICH" --version 2>&1); rc=$?
  assert_exit 0 "$rc" "opt: --version works"

  # -h / --help
  out=$("$WHICH" -h 2>&1); rc=$?
  assert_exit 0 "$rc" "opt: -h returns 0"
  assert_contains "Usage:" "$out" "opt: -h shows usage"

  out=$("$WHICH" --help 2>&1); rc=$?
  assert_exit 0 "$rc" "opt: --help works"

  # Combined options
  out=$(PATH="$TESTPATH" "$WHICH" -ac symcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "opt: -ac combined works"

  out=$(PATH="$TESTPATH" "$WHICH" -sa testcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "opt: -sa combined works"
  assert_empty "$out" "opt: -sa still silent"

  out=$(PATH="$TESTPATH" "$WHICH" -as testcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "opt: -as combined works"

  # --- EXIT CODES ---
  echo "# Exit codes"

  "$WHICH" ls >/dev/null 2>&1; rc=$?
  assert_exit 0 "$rc" "exit: 0 when found"

  "$WHICH" nonexistent_xyz >/dev/null 2>&1; rc=$?
  assert_exit 1 "$rc" "exit: 1 when not found"

  "$WHICH" 2>/dev/null; rc=$?
  assert_exit 1 "$rc" "exit: 1 when no args"

  "$WHICH" -z 2>/dev/null; rc=$?
  assert_exit 2 "$rc" "exit: 2 for invalid option"

  "$WHICH" --badopt 2>/dev/null; rc=$?
  assert_exit 2 "$rc" "exit: 2 for invalid long option"

  # --- PATH HANDLING ---
  echo "# PATH handling"

  # Leading colon (cwd first)
  cd "$TESTDIR"
  out=$(PATH=":/usr/bin:$TESTDIR/bin1" "$WHICH" cwdcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "path: leading colon finds cwd"
  cd "$SCRIPT_DIR"

  # Trailing colon (cwd last)
  cd "$TESTDIR"
  out=$(PATH="/usr/bin:$TESTDIR/bin1:" "$WHICH" cwdcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "path: trailing colon finds cwd"
  cd "$SCRIPT_DIR"

  # Double colon (cwd in middle)
  cd "$TESTDIR"
  out=$(PATH="/usr/bin:$TESTDIR/bin1::$TESTDIR/bin2" "$WHICH" cwdcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "path: double colon finds cwd"
  cd "$SCRIPT_DIR"

  # Empty PATH
  out=$(PATH="" "$WHICH" ls 2>&1); rc=$?
  assert_exit 1 "$rc" "path: empty PATH returns 1"

  # PATH with non-existent directories
  out=$(PATH="/nonexistent:/usr/bin:$TESTDIR/bin1" "$WHICH" testcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "path: skips non-existent dirs"

  # Single dot in PATH
  cd "$TESTDIR"
  out=$(PATH=".:/usr/bin" "$WHICH" cwdcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "path: explicit dot works"
  cd "$SCRIPT_DIR"

  # --- INPUT HANDLING ---
  echo "# Input handling"

  # Absolute path
  out=$("$WHICH" /usr/bin/ls 2>&1); rc=$?
  assert_exit 0 "$rc" "input: absolute path"
  assert_output "/usr/bin/ls" "$out" "input: absolute path output"

  # Relative path
  cd "$TESTDIR"
  out=$("$WHICH" ./cwdcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "input: relative path"
  cd "$SCRIPT_DIR"

  # -- separator
  out=$(PATH="$TESTPATH" "$WHICH" -- testcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "input: -- separator"

  # Command starting with hyphen
  out=$(PATH="$TESTPATH" "$WHICH" -- -hyphen 2>&1); rc=$?
  assert_exit 0 "$rc" "input: hyphen command via --"

  # --- EDGE CASES ---
  echo "# Edge cases"

  # Non-executable not matched
  out=$(PATH="$TESTPATH" "$WHICH" noexec 2>&1); rc=$?
  assert_exit 1 "$rc" "edge: non-executable not matched"

  # Directory not matched
  out=$(PATH="$TESTPATH" "$WHICH" testdir 2>&1); rc=$?
  assert_exit 1 "$rc" "edge: directory not matched"

  # Multi-level symlink resolution
  out=$(PATH="$TESTPATH" "$WHICH" -c sym2cmd 2>&1); rc=$?
  assert_exit 0 "$rc" "edge: multi-level symlink resolved"
  assert_contains "testcmd" "$out" "edge: resolves to final target"

  # --- BACKWARD COMPAT WITH DEBIANUTILS ---
  echo "# Debianutils backward compatibility"

  # -a flag works identically
  out=$(PATH="$TESTPATH" "$WHICH" -a testcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "compat: -a works"

  # -s flag works (debianutils has -s)
  out=$(PATH="$TESTPATH" "$WHICH" -s testcmd 2>&1); rc=$?
  assert_exit 0 "$rc" "compat: -s works"
  assert_empty "$out" "compat: -s produces no output"

  # No-args returns 1 (same as debianutils)
  "$WHICH" 2>/dev/null; rc=$?
  assert_exit 1 "$rc" "compat: no-args returns 1"

  # --- SUMMARY ---
  echo
  printf '1..%d\n' "$tests"
  printf '# %d tests, %d passed, %d failed\n' "$tests" "$passed" "$failed"

  return "$failed"
}

setup
run_tests
