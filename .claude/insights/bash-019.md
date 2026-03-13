# Custom PATH must include utilities called within scripts

When testing with a restricted PATH environment, external utilities invoked *inside* the script (like `realpath`, `grep`, `sed`) must be reachable via that PATH. Although the shebang uses an absolute interpreter path (`#!/usr/bin/bash`), commands executed during script runtime still depend on the active PATH variable. This applies to both direct calls and calls within functions or subshells. Ensure custom PATH configurations include all directories containing utilities the script depends on, or use absolute paths to invoke external commands.

---
*/ai/scripts/File/whichx | session 35040476 | 2026-03-12*
<!-- hash: b5befd33762b09f1e6a358120e6bfc30 -->
<!-- general: true -->
