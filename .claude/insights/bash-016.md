# POSIX sh IFS splitting loses trailing empty fields

In POSIX `sh`, when using `IFS=: for x in $PATH`, a trailing colon is silently dropped—`"/usr/bin:"` splits to `("/usr/bin")`, losing the implicit current directory. The fix appends an extra `:` so the trailing element becomes an explicit empty string that survives the split. Bash's `read -ra` avoids this entirely by preserving all fields. Also use `set -f` (noglob) when iterating PATH to prevent accidental glob expansion (`*`, `?`, `[`) if directory names contain these characters—a defensive best practice in robust POSIX shell code.

---
*/ai/scripts/File/whichx | session 671849a9 | 2026-03-12*
<!-- hash: 4a404cea9afa7972897ead3b93351980 -->
<!-- general: true -->
