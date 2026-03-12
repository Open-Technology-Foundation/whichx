# Bash option splitting and function export mechanics

Combined option splitting uses the pattern `-[acsVh]?*` to match a dash followed by a valid option character and any trailing characters. The `set --` trick replaces `$1` with the first two characters and prepends remaining characters as a new `-` argument. Using `continue` without `shift` re-enters the loop, achieving elegant recursive decomposition of combined options.

`declare -fx` applies the `-f` flag to target functions (not variables) and `-x` to export them. Together, this makes the function available in child bash processes via environment variables—the same mechanism underlying Shellshock, but used intentionally here for sourced-mode execution contexts.

---
*/ai/scripts/File/whichx | session 671849a9 | 2026-03-12*
<!-- hash: 91501994e0860f6f163feb170d9d35c5 -->
<!-- general: true -->
