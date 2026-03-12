# Unix exit codes and portable shell print patterns

Exit code conventions differ between use cases: exit 1 typically means "not found" while exit 2 means "usage error" (the standard for tools like `grep` and `diff`). The debianutils `which` implementation uses exit 2 for invalid options rather than exit 22 (EINVAL), following CLI conventions.

For shell portability, `ksh`'s `print -r --` pattern appears in debianutils: the `-r` flag disables backslash interpretation and `--` prevents leading-dash arguments from being misinterpreted as flags. Though it costs ~4 extra lines versus `printf '%s\n'`, using `KSH_VERSION` guards signals awareness of real-world shell diversity beyond bash.

---
*/ai/scripts/File/whichx | session 723135cc | 2026-03-11*
<!-- hash: 51a743bdb3045b824fc916d9d426932c -->
<!-- general: true -->
