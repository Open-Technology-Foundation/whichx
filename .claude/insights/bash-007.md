# Bash limitations with symlink resolution and syscalls

Bash has `[[ -L "$path" ]]` to detect symlinks, but no builtin to read their targets. Symlink targets are stored in the inode and require a syscall (`readlinkat(2)`) to retrieve — bash doesn't expose this. `cd -P` works for directories because it uses `chdir()` + `getcwd()`, which the OS resolves automatically. For practical symlink resolution, rely on coreutils (`realpath`, `readlink`) which are present on every Linux system. A loop using plain `readlink` is the closest approach to a pure-bash implementation, but coreutils are simpler and more reliable.

---
*/ai/scripts/File/whichx | session 723135cc | 2026-03-11*
<!-- hash: da6f8e8858f7297c7230d108ffabe92d -->
<!-- general: true -->
