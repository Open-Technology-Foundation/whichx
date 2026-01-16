# whichx

**Locate executables in PATH — robust `which` replacement**

Version 2.0 | [GPL-3.0](LICENSE) | Bash 4.4+

```bash
git clone https://github.com/Open-Technology-Foundation/whichx.git && cd whichx && sudo make install
```

---

## Why whichx?

Standard `which` varies across systems. `whichx` provides:

- **Predictable exit codes** (0, 1, 2, 22)
- **Canonical path resolution** (`-c`)
- **Silent mode** for scripting (`-q`/`-s`)
- **POSIX-compliant PATH handling**

## Quick Start

```bash
whichx python3              # Find python3
whichx -a python3           # All matches in PATH
whichx -c /usr/bin/python3  # Resolve symlinks
whichx -q docker || exit 1  # Silent check
```

---

## Installation

```bash
git clone https://github.com/Open-Technology-Foundation/whichx.git
cd whichx
sudo make install
```

Installs to `/usr/local/bin/whichx` with `which` symlink and man pages.

```bash
sudo make install PREFIX=/opt  # Custom prefix
sudo make uninstall            # Remove
```

### Requirements

- bash 4.4+
- realpath or readlink (for `-c`)

---

## Usage

```
whichx [OPTIONS] [--] command ...
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
$ whichx ls
/usr/bin/ls

$ whichx -a python3
/usr/bin/python3
/usr/local/bin/python3

$ whichx -c python3
/usr/bin/python3.12

$ whichx -q gcc make || echo "Missing tools"
```

### Scripting

```bash
# Pre-flight check
for tool in git curl jq; do
  whichx -q "$tool" || { echo "Missing: $tool" >&2; exit 1; }
done

# Tool selection
PYTHON=$(whichx python3 2>/dev/null || whichx python)
"$PYTHON" script.py
```

---

## POSIX Compliance

Empty PATH elements = current directory:

```bash
PATH=":/usr/bin" whichx ./script   # Leading colon
PATH="/usr/bin:" whichx ./script   # Trailing colon
```

---

## Development

```bash
make test       # shellcheck validation
shellcheck whichx
```

### Project Structure

```
whichx/
├── whichx      # Main executable (~120 lines)
├── whichx.1    # Man page
├── Makefile
├── LICENSE
└── README.md
```

---

## License

GPL-3.0 — see [LICENSE](LICENSE)

**Indonesian Open Technology Foundation** (admin@yatti.id)

---

## See Also

`man whichx` | `which(1)` | `whereis(1)` | `type(1)` | `command(1)`
