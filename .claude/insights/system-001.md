# Debian Essential Package Constraints Require Alternatives System

The `which` command from `debianutils` is marked `Essential: yes` and `Priority: required`, meaning it cannot be removed from Debian systems without special approval. Your Bash 5.2+ implementation cannot replace it directly due to Debian policy preferring `/bin/sh` (dash) for system scripts.

**Solution: Use `update-alternatives`**

Debian already manages `which` through the alternatives system. Register your implementation as an alternative with a higher priority to override the default `which` without replacing the `debianutils` package itself:

```bash
update-alternatives --install /usr/bin/which which /path/to/your/which 100
```

This approach:
- Respects Debian's Essential package constraints
- Avoids policy conflicts
- Allows users to switch between implementations
- Integrates with existing Debian infrastructure

The blocker is not code quality but policy — the alternatives system is the realistic path forward.

---
*/ai/scripts/File/whichx | session 61a8b98a | 2026-03-11*
<!-- hash: f8184f9b71938f30d21efb9a21e6ee29 -->
<!-- general: true -->
