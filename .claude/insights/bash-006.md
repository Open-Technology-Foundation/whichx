# Debian which utility behavior matched implementation

The `which.debianutils` source confirms the implemented behavior: no arguments silently sets `ALLRET=1` and falls through without error output (lines 29-31), and invalid options trigger exit code 2 via `getopts`'s `?` case (line 24). Implementation now matches this reference behavior precisely.

Version evolution shows progression from `core22` (Ubuntu 22.04) to `debianutils` with addition of `-s` (silent) flag in current Debian. The ksh guard has been present since the original implementation. The nodejs `which` package variant represents an entirely separate lineage from npm.

---
*/ai/scripts/File/whichx | session 723135cc | 2026-03-11*
<!-- hash: c4c438948cc779752c5252cede1725c6 -->
<!-- general: true -->
