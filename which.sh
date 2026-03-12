#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2025-2026 Indonesian Open Technology Foundation (admin@yatti.id)
# which - locate executables in PATH
# POSIX /bin/sh version for Debian packaging
# Usage: which [-acshV] [--] command ...
# -e: exit on error; -f: disable globbing (PATH dirs may contain wildcards)
set -ef

SILENT=0
ALLMATCHES=0
CANONICAL=0

puts() {
  [ "$SILENT" -eq 1 ] && return
  printf '%s\n' "$*"
}

show_help() {
  cat <<'HELP'
which 2.0 - Locate executables in PATH

Usage: which [OPTIONS] [--] command ...

Options:
  -a, --all        Print all matches, not just first
  -c, --canonical  Resolve symlinks via realpath
  -s, --silent     No output, exit code only
  -V, --version    Print version
  -h, --help       This help

Exit: 0=found, 1=not found, 2=bad option
HELP
}

# Parse options (manual long-option support since getopts is short-only)
while [ $# -gt 0 ]; do
  case "$1" in
    -a|--all)       ALLMATCHES=1 ;;
    -c|--canonical) CANONICAL=1 ;;
    -s|--silent)    SILENT=1 ;;
    -V|--version)   printf 'which 2.0\n'
                    exit 0 ;;
    -h|--help)      show_help
                    exit 0 ;;
    --)             shift; break ;;
    -[acsVh]?*)
      # Split combined short options: -ac -> -a -c
      rest="${1#??}"
      first="${1%"$rest"}"
      shift
      set -- "$first" "-$rest" "$@"
      continue
      ;;
    -*)             printf "Illegal option '%s'\n" "$1" >&2
                    exit 2 ;;
    *)              break ;;
  esac
  shift
done

if [ "$#" -eq 0 ]; then
  exit 1
fi

ALLRET=0

# Ensure trailing PATH element survives IFS=: split (POSIX: trailing : = cwd)
case $PATH in
  (*[!:]:) PATH="$PATH:" ;;
esac

for TARGET do
  FOUND=0

  case $TARGET in
    */*)
      if [ -f "$TARGET" ] && [ -x "$TARGET" ]; then
        if [ "$CANONICAL" -eq 1 ]; then
          RESOLVED=$(realpath -- "$TARGET" 2>/dev/null)
          if [ -n "$RESOLVED" ]; then
            puts "$RESOLVED"
            FOUND=1
          else
            [ "$SILENT" -eq 1 ] || printf "Cannot resolve canonical path for '%s'\n" "$TARGET" >&2
          fi
        else
          puts "$TARGET"
          FOUND=1
        fi
      fi
      [ "$FOUND" -eq 1 ] || ALLRET=1
      continue
      ;;
  esac

  # Split PATH on colons (save/restore IFS — no arrays in POSIX sh)
  IFS_SAVE="$IFS"
  IFS=:
  for ELEMENT in $PATH; do
    # POSIX: empty PATH element means current directory
    if [ -z "$ELEMENT" ]; then
      ELEMENT=.
    fi
    FULLPATH="${ELEMENT%/}/$TARGET"
    if [ -f "$FULLPATH" ] && [ -x "$FULLPATH" ]; then
      if [ "$CANONICAL" -eq 1 ]; then
        RESOLVED=$(realpath -- "$FULLPATH" 2>/dev/null)
        if [ -n "$RESOLVED" ]; then
          puts "$RESOLVED"
          FOUND=1
        else
          [ "$SILENT" -eq 1 ] || printf "Cannot resolve canonical path for '%s'\n" "$FULLPATH" >&2
        fi
      else
        puts "$FULLPATH"
        FOUND=1
      fi
      [ "$ALLMATCHES" -eq 1 ] || break
    fi
  done
  IFS="$IFS_SAVE"

  [ "$FOUND" -eq 1 ] || ALLRET=1
done

exit "$ALLRET"
#fin
