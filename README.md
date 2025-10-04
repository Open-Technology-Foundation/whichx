# whichx - Goodbye which

A robust bash implementation of the classic Unix `which` command with enhanced features and comprehensive error handling.

## Overview

`whichx` is a **fully-compatible drop-in replacement** for the standard `which` command. It locates executable files in your PATH environment variable, returning the pathnames of files that would be executed in the current environment. While maintaining 100% compatibility with the standard `which` command, `whichx` provides more robust error handling, better POSIX compliance, and additional features for modern shell scripting.

### Why whichx?

The standard `which` command varies across Unix systems, with inconsistent behavior and limited error reporting. `whichx` provides:

- **Consistent behavior** across all systems (pure bash implementation)
- **Specific exit codes** for different error conditions (not just 0/1)
- **Canonical path resolution** for following symlinks
- **Proper POSIX compliance** in PATH parsing and search behavior
- **Silent mode** for clean scripting without output noise
- **Enhanced error messages** with clear diagnostics

## Features

- **POSIX-compliant PATH searching** with proper handling of empty PATH elements
- **Multiple target support** - search for several commands in a single invocation
- **Canonical path resolution** via `-c` option to follow symlinks
- **Silent mode** (`-s`) for scripting - no output, just exit codes
- **Show all matches** (`-a`) to find every matching executable in PATH
- **Specific exit codes** for precise error handling in scripts
- **Embedded documentation** accessible via `--help`
- **Zero dependencies** beyond bash and standard Unix utilities

## Installation

### Direct Download

```bash
# Download the script
curl -O https://raw.githubusercontent.com/Open-Technology-Foundation/whichx/main/whichx

# Make it executable
chmod +x whichx

# Move to a directory in your PATH
sudo mv whichx /usr/local/bin/
```

### Clone Repository

```bash
git clone https://github.com/Open-Technology-Foundation/whichx.git
cd whichx
chmod +x whichx
sudo cp whichx /usr/local/bin/
```

### As a Drop-in Replacement for `which`

Since `whichx` is fully compatible with the standard `which` command, you can create a symlink to use it as a complete replacement:

```bash
# After installing whichx to /usr/local/bin/
sudo ln -s /usr/local/bin/whichx /usr/local/bin/which
```

This allows you to use `whichx` when calling `which` while maintaining all standard functionality.

### Requirements

- bash 4.3 or later
- `readlink` (for canonical path resolution with `-c` option)
- Standard Unix environment

## Usage

```bash
whichx [OPTIONS] filename ...
```

### Options

| Option | Long Form | Description |
|--------|-----------|-------------|
| `-a` | `--all` | Print all matching pathnames of each argument |
| `-c` | `--canonical` | Print canonical paths using readlink |
| `-s` | `--silent` | Silent mode - no output, exit codes only |
| `-V` | `--version` | Print version information |
| `-h` | `--help` | Display help message |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All specified commands found |
| 1 | One or more commands not found |
| 2 | Usage error (missing arguments) |
| 22 | Invalid option |

## Examples

### Basic Usage

```bash
# Find location of ls command
whichx ls
# Output: /usr/bin/ls
```

### Find All Matches

```bash
# Find all python executables in PATH
whichx -a python
# Output: /usr/bin/python
#         /usr/local/bin/python
```

### Canonical Path Resolution

```bash
# Show canonical path (follow symlinks)
whichx -c vim
# Output: /usr/bin/vim.basic
```

### Check Multiple Commands

```bash
# Search for multiple commands at once
whichx ls cat grep
# Output: /usr/bin/ls
#         /usr/bin/cat
#         /usr/bin/grep
```

### Silent Mode for Scripting

```bash
# Check if command exists without output
if whichx -s docker; then
  echo "Docker is installed"
else
  echo "Docker not found"
fi
```

### Exit Code Handling

```bash
# Use specific exit codes for error handling
whichx nonexistent-command
echo "Exit code: $?"
# Output: Exit code: 1

whichx --invalid-option
echo "Exit code: $?"
# Output: Exit code: 22
```

### Combine Options

```bash
# Find all matches and show canonical paths
whichx -a -c python3
```

## Use Cases

### Pre-flight Checks in Scripts

```bash
#!/bin/bash
# Check for required dependencies
if ! whichx -s docker docker-compose kubectl; then
  echo "Error: Missing required tools" >&2
  exit 1
fi
```

### Path Verification

```bash
# Verify which version of a command will be executed
echo "Using Python at: $(whichx python3)"
```

### CI/CD Pipeline Validation

```bash
# Validate build environment has all required tools
whichx -s gcc make cmake || exit 1
```

## Comparison with Standard `which`

| Feature | Standard `which` | `whichx` |
|---------|------------------|----------|
| Find executables | ✓ | ✓ |
| Multiple targets | ✓ | ✓ |
| Show all matches | ✓ | ✓ |
| Canonical paths | ✗ | ✓ |
| Silent mode | Limited | ✓ |
| Specific exit codes | ✗ | ✓ |
| POSIX-compliant | Varies | ✓ |
| Consistent behavior | Varies | ✓ |

### Development

The script follows strict bash coding standards:
- POSIX-compliant implementation
- Comprehensive error handling with `set -euo pipefail`
- Proper variable scoping and declarations
- Embedded documentation for maintainability

## License

GNU General Public License v3.0 - see [LICENSE](LICENSE).

## See Also

- [BASH-CODING-STANDARD](https://github.com/Open-Technology-Foundation/bash-coding-standard)
- Standard Unix `which(1)` command
- `type` bash builtin
- `command -v` for portable command checking
