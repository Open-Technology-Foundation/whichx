# Dual-purpose bash scripts with scoped IFS patterns

Design bash scripts to work both as sourced functions and standalone executables by defining functions before `set -euo pipefail`, preventing strict mode from affecting the caller's shell. Use the canonical BCS0106 guard pattern `[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0` at script end to detect execution context.

For IFS manipulation, apply the BCS1003 scoping pattern: `IFS=':' read -ra path_dirs <<< "$path_str"` limits IFS changes only to the `read` command, never polluting global IFS. This prevents word-splitting bugs in subsequent operations and maintains predictable shell behavior.

---
*/ai/scripts/File/whichx | session 61a8b98a | 2026-03-11*
<!-- hash: 0d618ea9c6cd7a08889985f46f83dd53 -->
<!-- general: true -->
