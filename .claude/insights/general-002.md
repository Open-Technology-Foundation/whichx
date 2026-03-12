# Exit code alignment:** The code already returns 1 for no-args (matching debia...

**Exit code alignment:** The code already returns 1 for no-args (matching debianutils), but help text, man page, and tests still say 2. This happened in the recent refactor (`M which` in git status). We'll align everything to exit 1 for no-args — this is the right call for Debian backward compatibility.

**POSIX porting challenges:** The Bash version uses `local -i`, `local -a`, `[[ ]]`, `((...))`, `${var@Q}`, `read -ra`, `<<<`, and `declare -fx`. All of these must be replaced with POSIX equivalents. The dual-mode sourcing feature cannot be ported (BASH_SOURCE is Bash-only), so the POSIX version is script-only.

---
*/ai/scripts/File/whichx | session 80ca250b | 2026-03-11*
<!-- hash: a0b12341a65b46e730334e084e48b18f -->
<!-- general: true -->
