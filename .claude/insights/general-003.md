# - **`#!/usr/bin/bash` vs `#!/usr/bin/env bash`**: The `env` form searches PAT...

- **`#!/usr/bin/bash` vs `#!/usr/bin/env bash`**: The `env` form searches PATH for bash, which is more portable across systems where bash isn't at `/usr/bin/bash` (e.g., NixOS, FreeBSD). The hardcoded path is faster (skips `env` exec) and avoids PATH manipulation attacks — a reasonable choice when targeting Debian/Ubuntu where `/usr/bin/bash` is guaranteed.
- **Inlining `_error()`**: With `-q`/`--quiet` gone, the helper was only used in three places. Inlining eliminates a nested function definition inside the already-nested `which()`, reducing scope complexity. The trade-off is minor duplication of the `((silent)) || >&2 printf` pattern.

---
*/ai/scripts/File/whichx | session fc90ab71 | 2026-03-11*
<!-- hash: c4d09a831f4769d76fddd6abd08a8a18 -->
<!-- general: true -->
