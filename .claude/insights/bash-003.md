# PATH hardening in function scoping and runtime

When hardening PATH in a bash function, setting `PATH=/usr/local/bin:/usr/bin:/bin` before calling won't work if the function reads `${PATH:-}` at runtime. Instead, use `PATH="$_user_path" which "$@"` to pass the hardened PATH only to that specific command's environment, letting the function see the user's PATH for its own lookups while the shell uses the hardened PATH for command resolution (e.g., `realpath`/`readlink`).

**Nested function scoping**: Defining helper functions like `_which_help` and `_error` inside `which()` makes them truly private—created on each call and destroyed on return. This is cleaner than top-level `_which_*` helpers, though it incurs a micro-cost of re-definition per invocation.

---
*/ai/scripts/File/whichx | session 61a8b98a | 2026-03-11*
<!-- hash: 60c01b3524f1f8c5ad951aa43ff68446 -->
<!-- general: true -->
