# Handle trailing colons in IFS-split PATH variables

Bash's `IFS=':' read -ra <<< "$PATH"` silently drops trailing empty fields. When PATH ends with `:` (meaning "include cwd"), the empty element is lost during the split. To preserve trailing empty fields, append a colon to the variable before splitting: `PATH="$PATH:"`. This ensures the `IFS=:` split treats the final empty string as a non-trailing field rather than discarding it. This pattern is essential for preserving semantic meaning in colon-delimited paths where an empty element represents a valid directory (like the current working directory).

---
*/ai/scripts/File/whichx | session 35040476 | 2026-03-12*
<!-- hash: 6d2afdbf5f8388f3ee6fc90fa9cf25f8 -->
<!-- general: true -->
