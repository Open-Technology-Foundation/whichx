# Exit codes and portability trade-offs in which refactor

Refactoring `which` involved three notable trade-offs:

1. **Exit code granularity**: Old code distinguished between no args (`2`) and bad option (`22`), enabling caller diagnostics. New code collapses both to `1`/`2`, matching traditional `which` behavior but losing precision.

2. **Portability safety net**: Removed `readlink -f` fallback for systems where `realpath` unavailable (older macOS, BusyBox). This was defensive against environments lacking `realpath`.

3. **Option parsing inconsistency**: The character class `-[acsqVh]?*` still splits combined options like `-qs` into `-q -s`, but `-q` alone now errors as "Illegal option". Users relying on `-q` in combinations may encounter unexpected failures during argument splitting before the error is raised.

---
*/ai/scripts/File/whichx | session fc90ab71 | 2026-03-11*
<!-- hash: 79247d150f408b42369711796f279d58 -->
<!-- general: true -->
