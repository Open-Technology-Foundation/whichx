# Bash read -ra trailing empty fields and compatibility testing

Bash `read -ra <<<` drops trailing empty fields—a well-known gotcha when splitting strings. The solution is a guard pattern: append a delimiter to ensure no data loss (e.g., `PATH="$PATH:"`). This approach matches POSIX implementations and prevents silent field loss.

For compatibility testing, run identical invocations against both the target implementation and legacy binaries, comparing exit codes and stdout. Discard stderr since error message formatting typically differs across versions. Organize tests by legacy binary with graceful TAP `skip` directives for missing implementations.

---
*/ai/scripts/File/whichx | session 35040476 | 2026-03-12*
<!-- hash: c01a2824b0df1e82a04ce3c5f53c5740 -->
<!-- general: true -->
