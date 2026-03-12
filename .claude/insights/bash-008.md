# Exit codes and variable naming already standardized

All three planned improvements were already implemented in the working tree:

1. **Exit code 2 for invalid options** — Both `which` and `whichx` scripts use `return 2`/`exit 2` when invalid options are encountered, with tests asserting this behavior and the man page documenting it.

2. **Silent no-args behavior** — Both scripts silently return/exit with code 1 when called with no arguments, producing no error message to stderr.

3. **Variable naming standardization** — The `which` script uses consistent lowercase variable names: `allmatches`, `allret`, `silent`, `canonical`, and `found`.

This indicates the codebase already follows established conventions for error handling and code clarity, reducing the scope of refactoring work needed.

---
*/ai/scripts/File/whichx | session 83eaa765 | 2026-03-11*
<!-- hash: a0595b7f3e78616cbc72d95d91e24372 -->
<!-- general: true -->
