# POSIX portability trade-offs and Debian alternatives registration

POSIX `which.sh` loses dual-mode sourcing capability since `BASH_SOURCE` is unavailable in POSIX sh. Substring operations must use string manipulation (`${1#??}`, `${1%"$rest"}`) instead of Bash-specific syntax like `${1:0:2}`. The `${var@Q}` quoting operator for error messages becomes simple single-quote wrapping. Despite these limitations, the POSIX version passes 54 tests covering all features except sourced mode.

When installing via Debian's alternatives system, register at priority 10 (debianutils defaults to 0) so `which.yatti` automatically becomes the active `which` binary after installation. Administrators can still use `update-alternatives --config which` to switch back manually. Slave links ensure the man page follows the binary selection.

---
*/ai/scripts/File/whichx | session 80ca250b | 2026-03-11*
<!-- hash: 407c23811b452011c9125f766eb55d13 -->
<!-- general: true -->
