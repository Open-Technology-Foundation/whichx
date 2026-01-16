# which

A robust, POSIX-compliant `which` replacement for Bash.

[![License: GPL-3.0](https://img.shields.io/badge/License-GPL%203.0-blue.svg)](LICENSE)
[![Bash 4.4+](https://img.shields.io/badge/Bash-4.4%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Tests: 51 passing](https://img.shields.io/badge/Tests-51%20passing-brightgreen.svg)](tests/)

## TL;DR

```bash
git clone https://github.com/Open-Technology-Foundation/whichx.git
cd whichx && sudo make install
which -a python3
```

## Why Replace which?

The standard `which` command varies significantly across Unix systems:

| Issue | Debian | macOS | Busybox |
|-------|--------|-------|---------|
| Exit code (no args) | 1 | 0 | 0 |
| Exit code (bad option) | 2 | 1 | 1 |
| `-s` silent mode | No | Yes | No |
| Long options | No | No | No |

This implementation provides:

- **Consistent exit codes**: 0 (found), 1 (not found), 2 (no args), 22 (EINVAL)
- **POSIX PATH compliance**: Correct handling of empty PATH elements
- **Dual-mode execution**: Run as script OR source as function (12x faster)
- **Canonical resolution**: Follow symlinks to actual executables

## Installation

### Quick Install

```bash
git clone https://github.com/Open-Technology-Foundation/whichx.git
cd whichx && sudo make install
```

Installs to `/usr/local/bin/which` with man page.

### Custom Prefix

```bash
sudo make install PREFIX=/usr/bin
```

### Sourceable Install (Recommended for Interactive Use)

```bash
sudo make install-sourceable
```

This copies the script to `/etc/profile.d/which.sh`. New shells will have `which()` as a shell function instead of calling an external process.

**Why is this faster?** Each external command invocation requires fork() + exec() + bash interpreter startup (~1.6ms). A shell function runs in-process (~0.13ms). That's **12x faster**.

**Note:** `/etc/profile.d/` is sourced by login shells via `/etc/profile`. Most terminal emulators start non-login shells, which source `~/.bashrc` instead. If `which` isn't available in new terminals, either:
- Add `source /etc/profile.d/which.sh` to your `~/.bashrc`, or
- Configure your terminal to start login shells

### Uninstall

```bash
sudo make uninstall
sudo make uninstall-sourceable
```

## Usage

```
which [OPTIONS] [--] command ...
```

### Options

| Option | Long | Description |
|--------|------|-------------|
| `-a` | `--all` | Print all matches in PATH, not just first |
| `-c` | `--canonical` | Resolve symlinks via realpath/readlink |
| `-q` | `--quiet` | No output, exit code only |
| `-s` | `--silent` | Alias for `-q` |
| `-V` | `--version` | Print version and exit |
| `-h` | `--help` | Print help and exit |

Options can be combined: `-ac` equals `-a -c`

### Exit Codes

| Code | Constant | Meaning |
|------|----------|---------|
| 0 | `EXIT_SUCCESS` | All commands found |
| 1 | `EXIT_FAILURE` | One or more not found |
| 2 | `EXIT_USAGE` | No arguments provided |
| 22 | `EINVAL` | Invalid option |

### Examples

```bash
which ls                      # /usr/bin/ls
which -a python3              # All python3 in PATH
which -c /usr/bin/python3     # Resolves to /usr/bin/python3.12
which -q docker && echo "ok"  # Silent check
which ls cat grep             # Multiple commands
which -- -weird-name          # Command starting with hyphen
```

## Architecture

### Dual-Mode Design

The script works both as an executable and as a sourceable function:

```bash
# As executable (subprocess)
./which ls

# As sourced function (in-process)
source ./which
which ls
```

This is achieved with the `BASH_SOURCE` guard:

```bash
which() {
  # ... function body ...
}
declare -fx which

[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

# --- Script mode (direct execution only) ---
set -euo pipefail
shopt -s inherit_errexit

which_help() { ... }
which "$@"
```

When sourced, `BASH_SOURCE[0]` differs from `$0`, so `return 0` exits early after defining the function. When executed, they match, so the script continues to run `which "$@"`.

### Strict Mode Without Pollution

Traditional bash scripts use strict mode at the top, but this would pollute the sourcing shell's environment. This script solves that by placing strict mode **after** the BASH_SOURCE guard:

- **Sourced**: Returns before reaching `set -euo pipefail` — caller's shell unaffected
- **Executed**: Strict mode applies only to the subprocess

### Function Structure

All logic lives in a single `which()` function with:

- All variables declared `local` (no namespace pollution)
- `return` instead of `exit` (function-safe)
- Inline PATH parsing (no helper functions to leak)
- Conditional help: brief when sourced, full when executed

### PATH Parsing

```bash
path_str=${PATH:-}
[[ $path_str == *: ]] && path_str+='.'  # Trailing colon = cwd
IFS=':' read -ra path_dirs <<< "$path_str"

for path in "${path_dirs[@]}"; do
  [[ -n $path ]] || path='.'  # Empty element = cwd
  # ...
done
```

The `read -ra` with herestring is a common idiom, but it drops trailing empty elements. The `*:` check handles trailing colons explicitly.

## POSIX Compliance

Per POSIX, an empty element in PATH means the current directory. Many `which` implementations get this wrong.

```bash
# Leading colon = cwd searched first
PATH=":/usr/bin" which ./script

# Trailing colon = cwd searched last
PATH="/usr/bin:" which ./script

# Double colon = cwd searched in middle
PATH="/usr/bin::/usr/local/bin" which ./script
```

This matters for security audits and understanding command resolution.

## Performance

### Methodology

Benchmarks run each command 1000 times, measuring wall-clock time with nanosecond precision.

### Results

| Test | which (subprocess) | which (sourced) | old.which (dash) |
|------|-------------------|-----------------|------------------|
| Single lookup | ~600 ops/s | ~7,500 ops/s | ~1,200 ops/s |
| Large PATH (50 dirs) | ~500 ops/s | ~6,000 ops/s | ~1,200 ops/s |
| Not found | ~600 ops/s | ~7,500 ops/s | ~1,200 ops/s |

### Analysis

**Why is subprocess mode 2x slower than dash-based which?**

Bash has more startup overhead than dash. The actual PATH searching is nearly identical, but bash's interpreter initialization dominates.

**Why is sourced mode 12x faster?**

No fork(), no exec(), no interpreter startup. The function runs directly in the current shell's process space.

### Run Benchmarks

```bash
make benchmark
```

## Testing

### Run Tests

```bash
make test         # shellcheck + functional tests
make shellcheck   # Static analysis only
make functional   # 51 functional tests only
```

### Test Coverage

- Basic operations (find, not found, multiple targets)
- All options (`-a`, `-c`, `-q`, `-s`, `-V`, `-h`, `--long`)
- Combined options (`-ac`, `-qa`, `-aqs`)
- Exit codes (0, 1, 2, 22)
- PATH edge cases (leading/trailing/double colon, empty, nonexistent dirs)
- Input handling (absolute path, relative path, `--` separator, hyphen commands)
- Edge cases (non-executable, directories, symlinks, broken symlinks)

### Adding Tests

Tests use TAP-style output. Add to `tests/test_which.sh`:

```bash
out=$("$WHICH" -a python3 2>&1); rc=$?
assert_exit 0 $rc "description"
assert_contains "python" "$out" "description"
```

## Contributing

### Code Style

- All variables `local` (sourceable requirement)
- Integer variables: `local -i count=0`
- Arrays: `local -a items=()`
- Conditionals: `[[ ]]` never `[ ]`
- Arithmetic: `(( ))` only
- 2-space indentation
- Quote all variable expansions
- Errors to stderr: `printf >&2`

### Requirements

- Must pass `shellcheck`
- Must pass all 51 tests
- No new dependencies

### Pull Requests

1. Fork the repository
2. Create a feature branch
3. Make changes
4. Run `make test`
5. Submit PR

## License

GPL-3.0-or-later — see [LICENSE](LICENSE)

**Indonesian Open Technology Foundation**
admin@yatti.id

## See Also

- `man which` — installed man page
- `type(1)` — bash builtin, shows aliases/functions too
- `command -v` — POSIX way to find commands
- `whereis(1)` — also searches man pages and source
