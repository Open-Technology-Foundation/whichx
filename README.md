# which

**Locate executables in PATH — robust `which` replacement**

Version 2.0 | [GPL-3.0](LICENSE) | Bash 4.4+

```bash
git clone https://github.com/Open-Technology-Foundation/whichx.git && cd whichx && sudo make install
```

---

## Why this which?

Standard `which` varies across systems. This implementation provides:

- **Predictable exit codes** (0, 1, 2, 22)
- **Canonical path resolution** (`-c`)
- **Silent mode** for scripting (`-q`/`-s`)
- **POSIX-compliant PATH handling**
- **Sourceable** for 12x faster interactive use

## Quick Start

```bash
which python3              # Find python3
which -a python3           # All matches in PATH
which -c /usr/bin/python3  # Resolve symlinks
which -q docker || exit 1  # Silent check
```

---

## Installation

```bash
git clone https://github.com/Open-Technology-Foundation/whichx.git
cd whichx
sudo make install
```

Installs to `/usr/local/bin/which` with man page.

```bash
sudo make install PREFIX=/opt  # Custom prefix
sudo make uninstall            # Remove
```

### Sourceable Installation (12x faster)

For interactive shells, source the script instead of calling it as subprocess:

```bash
sudo make install-sourceable   # Installs to /etc/profile.d/which.bash
```

New shells will have the `which()` function loaded (~7500 ops/s vs ~600 ops/s).

### Requirements

- bash 4.4+
- realpath or readlink (for `-c`)

---

## Usage

```
which [OPTIONS] [--] command ...
```

### Options

| Option | Description |
|--------|-------------|
| `-a, --all` | Print all matches, not just first |
| `-c, --canonical` | Resolve symlinks via realpath/readlink |
| `-q, --quiet` | No output, exit code only |
| `-s, --silent` | Same as `-q` |
| `-V, --version` | Print version |
| `-h, --help` | Help |

Options can be combined: `-ac` equals `-a -c`

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All commands found |
| 1 | One or more not found |
| 2 | No arguments |
| 22 | Invalid option |

---

## Examples

```bash
$ which ls
/usr/bin/ls

$ which -a python3
/usr/bin/python3
/usr/local/bin/python3

$ which -c python3
/usr/bin/python3.12

$ which -q gcc make || echo "Missing tools"
```

### Scripting

```bash
# Pre-flight check
for tool in git curl jq; do
  which -q "$tool" || { echo "Missing: $tool" >&2; exit 1; }
done

# Tool selection
PYTHON=$(which python3 2>/dev/null || which python)
"$PYTHON" script.py
```

---

## POSIX Compliance

Empty PATH elements = current directory:

```bash
PATH=":/usr/bin" which ./script   # Leading colon
PATH="/usr/bin:" which ./script   # Trailing colon
```

---

## Testing

```bash
make test         # shellcheck + functional tests (51 tests)
make shellcheck   # shellcheck only
make functional   # functional tests only
make benchmark    # performance comparison vs old.which
```

### Test Coverage

- Basic operations, all options, combined options
- Exit codes (0, 1, 2, 22)
- POSIX PATH edge cases (leading/trailing/double colon)
- Symlink resolution, broken symlinks
- Non-executable files, directories

### Benchmark (vs debianutils which)

| Test | which | old.which |
|------|-------|-----------|
| Single lookup | ~600 ops/s | ~1200 ops/s |
| Large PATH | ~500 ops/s | ~1200 ops/s |
| Sourced | ~7500 ops/s | N/A |

Subprocess is ~2x slower (bash vs dash) but sub-millisecond per operation.
Sourced function is 12x faster than subprocess.

---

## Project Structure

```
whichx/
├── which             # Main script (executable + sourceable)
├── which.1           # Man page
├── Makefile
├── tests/
│   ├── test_which.sh   # 51 functional tests
│   └── benchmark.sh    # Performance comparison
├── LICENSE
└── README.md
```

---

## License

GPL-3.0 — see [LICENSE](LICENSE)

**Indonesian Open Technology Foundation** (admin@yatti.id)

---

## See Also

`man which` | `whereis(1)` | `type(1)` | `command(1)`
