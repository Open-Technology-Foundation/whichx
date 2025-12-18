# whichx

**A robust, POSIX-compliant drop-in replacement for the Unix `which` command.**

Version 2.0 | [License: GPL-3.0](LICENSE) | Bash 4.3+

---

## Why whichx?

The standard `which` command varies significantly across Unix systems—different implementations, inconsistent exit codes, and unreliable behavior in scripts. `whichx` solves this by providing:

- **Predictable exit codes** for reliable scripting (0, 1, 2, 22)
- **Canonical path resolution** to follow symlinks to their true location
- **True silent mode** that suppresses all output for clean conditionals
- **POSIX-compliant PATH handling** including empty element support
- **Consistent behavior** across all Unix/Linux systems

## Quick Start

```bash
# Install
git clone https://github.com/Open-Technology-Foundation/whichx.git
cd whichx
sudo make install

# Use
whichx python3              # Find python3
whichx -a python3           # Find ALL python3 executables in PATH
whichx -c /usr/bin/python3  # Resolve symlinks to canonical path
whichx -s docker || exit 1  # Silent pre-flight check
```

---

## Installation

### From Source (Recommended)

```bash
git clone https://github.com/Open-Technology-Foundation/whichx.git
cd whichx
sudo make install
```

This installs:
- `/usr/local/bin/whichx` — the main executable
- `/usr/local/bin/which` — symlink to whichx
- `/usr/local/share/man/man1/whichx.1` — man page
- `/usr/local/share/man/man1/which.1` — man page symlink

### Custom Installation Prefix

```bash
sudo make install PREFIX=/opt/local
```

### Manual Installation

```bash
sudo install -m 755 whichx /usr/local/bin/
sudo ln -sf whichx /usr/local/bin/which
```

### Uninstall

```bash
sudo make uninstall
```

### Requirements

| Dependency | Version | Purpose |
|------------|---------|---------|
| bash | 4.3+ | Script interpreter |
| realpath | any | Canonical path resolution (`-c`) |
| grep | any | Combined option parsing |

---

## Usage

```
whichx [OPTIONS] filename ...
```

### Options

| Short | Long | Description |
|-------|------|-------------|
| `-a` | `--all` | Print all matching pathnames, not just the first |
| `-c` | `--canonical` | Resolve symlinks and print canonical paths |
| `-s` | `--silent` | Suppress all output; exit code only |
| `-V` | `--version` | Print version and exit |
| `-h` | `--help` | Display help and exit |

Options can be combined: `-ac` is equivalent to `-a -c`

### Exit Codes

| Code | Constant | Meaning |
|------|----------|---------|
| 0 | `EXIT_SUCCESS` | All specified commands found |
| 1 | `EXIT_NOT_FOUND` | One or more commands not found |
| 2 | `EXIT_USAGE_ERROR` | No arguments provided |
| 22 | `EXIT_INVALID_OPTION` | Invalid option (EINVAL) |

---

## Examples

### Basic Usage

```bash
# Find a command
$ whichx ls
/usr/bin/ls

# Find multiple commands
$ whichx ls cat grep
/usr/bin/ls
/usr/bin/cat
/usr/bin/grep

# Command not found (silent, check exit code)
$ whichx nonexistent
$ echo $?
1
```

### Find All Matches (`-a`)

When a command exists in multiple PATH directories:

```bash
$ whichx -a python3
/usr/bin/python3
/usr/local/bin/python3

$ whichx -a node
/usr/bin/node
/home/user/.nvm/versions/node/v20.0.0/bin/node
```

### Canonical Paths (`-c`)

Resolve symlinks to find the actual executable:

```bash
$ whichx python3
/usr/bin/python3

$ whichx -c python3
/usr/bin/python3.12

$ whichx -c vi
/usr/bin/vim.basic
```

### Silent Mode (`-s`)

Suppress all output for use in conditionals:

```bash
# Simple conditional
if whichx -s docker; then
    echo "Docker is available"
fi

# Pre-flight dependency check
whichx -s gcc make cmake || {
    echo "Missing build tools" >&2
    exit 1
}

# Inline conditional
whichx -s python3 && python3 script.py || python script.py
```

### Combined Options

```bash
# All matches with canonical paths
$ whichx -ac python3
/usr/bin/python3.12
/usr/local/bin/python3.11

# Silent check for all matches (useful for counting)
whichx -as python3 && echo "At least one python3 found"
```

### Direct Path Verification

Verify a specific path is executable:

```bash
$ whichx /usr/local/bin/my-script
/usr/local/bin/my-script

$ whichx ./local-tool
./local-tool
```

---

## Scripting Patterns

### Pre-flight Dependency Check

```bash
#!/bin/bash
# Verify all required tools exist before running

required_tools=(git curl jq docker)

for tool in "${required_tools[@]}"; do
    if ! whichx -s "$tool"; then
        echo "Error: Required tool '$tool' not found" >&2
        exit 1
    fi
done

echo "All dependencies satisfied"
```

### Version-Aware Tool Selection

```bash
#!/bin/bash
# Use python3 if available, fall back to python

if whichx -s python3; then
    PYTHON=$(whichx python3)
elif whichx -s python; then
    PYTHON=$(whichx python)
else
    echo "No Python interpreter found" >&2
    exit 1
fi

"$PYTHON" my_script.py
```

### Find Canonical Path for Logging

```bash
#!/bin/bash
# Log the actual executable being used (following symlinks)

TOOL=$(whichx -c node 2>/dev/null) || {
    echo "Node.js not found" >&2
    exit 1
}

echo "Using: $TOOL"
"$TOOL" --version
```

---

## POSIX Compliance

### Empty PATH Elements

Per POSIX, an empty element in PATH means the current directory. `whichx` handles this correctly:

```bash
# Leading colon = empty first element = current directory
$ PATH=":/usr/bin" whichx ./my-script
./my-script

# Trailing colon = empty last element
$ PATH="/usr/bin:" whichx ./local-tool
./local-tool

# Double colon = empty middle element
$ PATH="/usr/bin::/usr/local/bin" whichx ls
/usr/bin/ls
```

Most `which` implementations handle this inconsistently or incorrectly.

### Search Order

`whichx` searches PATH directories in order and returns the first match (unless `-a` is specified), exactly as a POSIX shell would resolve the command.

---

## Comparison with Standard `which`

| Feature | Standard `which` | `whichx` |
|---------|:----------------:|:--------:|
| Find executables | Yes | Yes |
| Multiple targets | Yes | Yes |
| Show all matches (`-a`) | Yes | Yes |
| Canonical paths (`-c`) | No | Yes |
| True silent mode | Partial | Yes |
| Specific exit codes | No | Yes |
| POSIX PATH compliance | Varies | Yes |
| Combined short options | Varies | Yes |
| Consistent cross-platform | No | Yes |

### Exit Code Comparison

| Scenario | GNU which | BSD which | whichx |
|----------|:---------:|:---------:|:------:|
| Found | 0 | 0 | 0 |
| Not found | 1 | 1 | 1 |
| No arguments | 1 | 1 | 2 |
| Invalid option | 1 or 2 | 1 | 22 |

`whichx` uses distinct exit codes so scripts can differentiate between "command not found" and "usage error."

---

## Development

### Validation

```bash
# Run shellcheck (required to pass)
make test

# Or directly
shellcheck whichx
```

### Code Style

This project follows the [Bash Coding Standard (BCS)](https://github.com/Open-Technology-Foundation/bash-coding-standard):

- `set -euo pipefail` with full shopt settings
- Proper variable typing (`declare -i`, `declare -a`, `declare -r`)
- `[[ ]]` conditionals, `(( ))` arithmetic
- Functions with documented return values
- Consistent 2-space indentation

### Project Structure

```
whichx/
├── whichx          # Main executable (159 lines)
├── whichx.1        # Man page (troff format)
├── Makefile        # Install/uninstall/test targets
├── LICENSE         # GPL-3.0
├── README.md       # This file
└── CLAUDE.md       # AI assistant context
```

---

## Contributing

Contributions are welcome! Please ensure:

1. Code passes `shellcheck whichx` with no warnings
2. Changes follow the [Bash Coding Standard](https://github.com/Open-Technology-Foundation/bash-coding-standard)
3. Update documentation if adding features
4. Test on bash 4.3+ (the minimum supported version)

---

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE) for details.

This is free software: you can redistribute it and/or modify it under the terms of the GPL. There is NO WARRANTY, to the extent permitted by law.

---

## Author

**Gary Dean** — [Open Technology Foundation](https://github.com/Open-Technology-Foundation)

---

## See Also

- Man page: `man whichx`
- [Bash Coding Standard](https://github.com/Open-Technology-Foundation/bash-coding-standard)
- Related commands: `which(1)`, `whereis(1)`, `type(1)`, `command(1)`
