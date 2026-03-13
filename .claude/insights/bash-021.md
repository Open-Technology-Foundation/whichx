# Behavioral parity achieved with cosmetic output differences

Confirmed that the new `which` implementation maintains full behavioral parity with the original for all functional aspects: PATH searching, `-a` flag, `-s` flag, and exit codes are identical. The only differences are cosmetic — error quoting styles and trailing slash normalization (e.g., `//` vs `/`). While double slashes in paths are valid POSIX and resolve identically, the new implementation produces cleaner output.

**`getopts` limitation**: The legacy approach using `getopts` cannot handle long options and truncates unrecognized options like `--badopt` to `--`, losing the actual option name in error messages. Consider this when deciding between `getopts` (simple, portable) and manual parsing (better error reporting).

---
*/ai/scripts/File/whichx | session 35040476 | 2026-03-12*
<!-- hash: 971f51b79348ca1eb6700795b2700e25 -->
<!-- general: true -->
