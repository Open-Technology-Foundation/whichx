# File permissions inheritance setgid parent constraints

Parent directory permissions gate access to child resources. When a parent dir has setgid (`drwxrwsr-x`), new files inherit the group automatically. However, files copied or transferred from elsewhere may retain their original ownership, bypassing setgid inheritance. Additionally, restrictive parent permissions (e.g., `700`) block group access to subdirectories beneath it, even if those subdirectories have permissive permissions like `2775` — the parent's permission constraints take precedence and prevent traversal.

---
*/ai/scripts/File/whichx | session 35040476 | 2026-03-12*
<!-- hash: def84c2ffe4328a788c31cd6ed3e8315 -->
<!-- general: true -->
