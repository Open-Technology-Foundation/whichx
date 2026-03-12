# Behavioral superset strategy for Debian compatibility

Design whichx as a strict behavioral superset of debianutils `which` rather than an identical clone. Existing scripts must produce identical results, but whichx can offer additional features like `-c`, `-q`, and `--help`. Close compatibility gaps with three key changes: (1) exit code 22→2 for missing arguments, (2) silent handling of no arguments, (3) ksh shell compatibility. This approach allows feature expansion while guaranteeing no breaking changes for existing deployments.

---
*/ai/scripts/File/whichx | session 723135cc | 2026-03-11*
<!-- hash: 59b7054ae77ee4b70e01f4a1d97a9c2d -->
<!-- general: true -->
