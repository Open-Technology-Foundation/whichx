# Optimize PATH parsing outside loop to reduce overhead

A trailing `:` in PATH represents the current directory (POSIX standard). The `<<<` here-string creates a temporary file internally, adding overhead. When this PATH-parsing block runs inside a `for target` loop, it re-parses the same PATH on every iteration even though PATH doesn't change. Move the PATH parsing outside the loop to parse once, then iterate over the results. This eliminates redundant re-parsing and reduces temporary file creation overhead significantly.

---
*/ai/scripts/File/whichx | session fc90ab71 | 2026-03-11*
<!-- hash: ffa56e3bdcf4baaca0ab95116bbe7efa -->
<!-- general: true -->
