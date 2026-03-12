# Simplify which by removing non-standard -q alias

Debian's `which` command (from debianutils) only officially supports the `-s` flag for silent mode. The `-q` option was added as a courtesy alias but creates unnecessary surface area for compatibility complaints and maintenance burden. Removing the `-q` alias simplifies the interface and avoids debates about non-standard options, while `-s` remains the canonical approach for silent operation.

---
*/ai/scripts/File/whichx | session 83eaa765 | 2026-03-11*
<!-- hash: ca4116a235b5df6a25e7a9fc38f41407 -->
<!-- general: true -->
