# whichx

A robust, fully-compatible drop-in replacement for the Unix `which` command.

## Overview

`whichx` locates executables in your PATH with enhanced features while maintaining 100% compatibility with standard `which`. It provides consistent behavior across all systems, specific exit codes, canonical path resolution, and better POSIX compliance.

**Key improvements over standard `which`:**
- Specific exit codes (0, 1, 2, 22) for precise error handling
- Canonical path resolution with `-c` option
- Enhanced silent mode for scripting
- Consistent behavior across all Unix systems
- Proper handling of empty PATH elements

## Installation

```bash
git clone https://github.com/Open-Technology-Foundation/whichx.git
cd whichx
sudo make install
```

Installs to `/usr/local/bin/` with manpages and creates `which` symlink. For custom locations: `sudo make install PREFIX=/opt/local`

**Requirements:** bash 4.3+, realpath

## Usage

```bash
whichx [OPTIONS] filename ...
```

See `man whichx` for detailed documentation.

### Options

| Option | Description |
|--------|-------------|
| `-a, --all` | Print all matching pathnames |
| `-c, --canonical` | Print canonical paths (resolve symlinks) |
| `-s, --silent` | Silent mode - exit codes only |
| `-V, --version` | Print version |
| `-h, --help` | Show help |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All commands found |
| 1 | One or more not found |
| 2 | Usage error |
| 22 | Invalid option |

## Examples

```bash
# Basic usage
whichx ls                           # /usr/bin/ls

# Find all matches
whichx -a python                    # All python executables in PATH

# Canonical paths (follow symlinks)
whichx -c vim                       # /usr/bin/vim.basic

# Silent mode for scripts
whichx -s docker && echo "Found"    # No output, check exit code

# Multiple commands
whichx ls cat grep                  # Find all three

# Pre-flight dependency checks
whichx -s gcc make cmake || exit 1
```

## Comparison with Standard `which`

| Feature | `which` | `whichx` |
|---------|---------|----------|
| Find executables | ✓ | ✓ |
| Multiple targets | ✓ | ✓ |
| Show all matches | ✓ | ✓ |
| Canonical paths | ✗ | ✓ |
| Silent mode | Limited | ✓ |
| Specific exit codes | ✗ | ✓ |
| POSIX-compliant | Varies | ✓ |
| Consistent behavior | Varies | ✓ |

## Contributing

Contributions welcome! The script follows strict [Bash Coding Standards](https://github.com/Open-Technology-Foundation/bash-coding-standard).

## License

GNU General Public License v3.0 - see [LICENSE](LICENSE).

## Author

Gary Dean

## See Also

- [BASH-CODING-STANDARD](https://github.com/Open-Technology-Foundation/bash-coding-standard)
- `which(1)`, `whereis(1)`, `type(1)`, `command(1)`
