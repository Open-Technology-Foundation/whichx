# POSIX sh adaptations for which implementation

When adapting bash scripts to POSIX sh, strategic function retention and removal matters:

**Function changes:**
- Retain `puts()` since POSIX sh lacks `((...))` arithmetic for inline silent-mode guards
- Remove `error()` because illegal option errors must always print (matching `which` behavior), while canonical path errors use simple inline `[ "$SILENT" -eq 1 ] ||` guards

**Quoting differences:**
- Bash's `${var@Q}` produces shell-quoted output (e.g., `$'--bad\noption'`)
- POSIX sh substitute: `printf '%s'` achieves equivalent visual quoting for typical option strings

**PATH parsing divergence:**
- Bash `read -ra` with `<<<` preserves trailing empty fields from trailing colons in PATH
- POSIX `for x in $PATH` with `IFS=:` strips trailing empties, requiring a `case` fixup that appends `:` to restore equivalent behavior
- Both approaches achieve same end result through different mechanisms

---
*/ai/scripts/File/whichx | session fc90ab71 | 2026-03-11*
<!-- hash: 4e97e3acbecf25d7dba893f12ea4b55d -->
<!-- general: true -->
