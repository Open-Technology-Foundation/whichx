# POSIX sh portability and glob safety in which

The `.sh` variant of `which` is pure POSIX `/bin/sh` with no bashisms—using `[ ]` instead of `[[ ]]`, manual IFS save/restore instead of `read -ra`, consistent `$var` quoting, and `exit` instead of `return`. This matters for Debian packaging where `/bin/sh` may be dash, not bash.

The `set -ef` combination is particularly important: `-e` (errexit) is common, but `-f` (noglob) prevents glob expansion of PATH elements containing `*` or `?` characters. Without `-f`, iterating over `$PATH` with `IFS=:` could unintentionally expand globs in directory names.

---
*/ai/scripts/File/whichx | session 671849a9 | 2026-03-12*
<!-- hash: 8b4086f93fa7cd1a5b8c0ba61a05c6c7 -->
<!-- general: true -->
