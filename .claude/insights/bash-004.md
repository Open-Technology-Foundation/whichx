# POSIX sh versus Bash portability and safety tradeoffs

The Debian `which.debianutils` uses `/bin/sh` for maximum portability across different shell implementations (dash, ksh, bash). A Bash 5.2+ target enables safer patterns unavailable in POSIX sh: `[[ ]]` for conditional expressions, `(( ))` for arithmetic, `local` for variable scoping, associative arrays, and `${var@Q}` for safe quoting. This tradeoff between portability and modern safety features is a key architectural decision when writing shell tools.

---
*/ai/scripts/File/whichx | session 61a8b98a | 2026-03-11*
<!-- hash: ac6bd1e111eead78351ae1011c461cce -->
<!-- general: true -->
