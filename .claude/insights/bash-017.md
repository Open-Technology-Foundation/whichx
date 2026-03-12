# Bash IFS read drops trailing empty fields from here-strings

The `IFS=':' read -ra <<< "$PATH"` pattern in bash loses trailing empty fields when splitting here-strings. This is problematic when PATH ends with `:` (POSIX convention for current directory), as the empty element representing the current directory is discarded.

**Workaround**: Use a guard clause to prevent trailing colons:
```bash
case $PATH in
  (*[!:]:) PATH="$PATH:" ;;
esac
IFS=':' read -ra arr <<< "$PATH"
```

This appends an extra colon so the trailing empty field becomes a middle field, which `IFS` splitting preserves. This technique comes from the legacy Debian implementation and ensures all PATH components, including implicit current directory entries, are captured correctly.

---
*/ai/scripts/File/whichx | session eab30011 | 2026-03-12*
<!-- hash: 198b72c1f2f5d55043547fa94ef1ed9a -->
<!-- general: true -->
