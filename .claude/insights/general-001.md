# Exit code alignment between implementation and documentation

When exit codes differ between implementation, tests, and documentation, prioritize consistency with established standards. In this case:

- Current code returns exit code 1 for no arguments (line 57)
- Test expects exit code 2 (line 193)
- Help text documents "2=no args"
- Reference implementation (`debianutils which`) returns 1 for no arguments

The fix is to align test and help text to match the working implementation, not modify working code. Additionally, note that `debianutils` uses exit code 2 for invalid options (while this script uses 22), and `debianutils` only supports `-a` and `-s` flags—no `-c`, `-h`, `-V`, or long options.

---
*/ai/scripts/File/whichx | session 80ca250b | 2026-03-11*
<!-- hash: d46d260fb8225ceb2530a456a4765435 -->
<!-- general: true -->
