# Absolute paths more secure than PATH hardening

Using absolute paths like `/usr/bin/realpath` directly is more secure and efficient than PATH hardening. It eliminates PATH lookup entirely—no hash table search or directory scanning. It's also self-documenting: you can see exactly which binary runs. The tradeoff is portability (some systems put these in `/bin/` instead), but on Ubuntu 24.04+ both live in `/usr/bin/`.

---
*/ai/scripts/File/whichx | session 61a8b98a | 2026-03-11*
<!-- hash: 3babd72e4b3a34b305651644d7f09c0f -->
<!-- general: true -->
