# Validate short options in combined-option splitter pattern

The combined-option splitter regex (`-[acsVh]?*`) should only include characters that are **valid** short options. Including invalid/dead letters causes confusing two-stage failures where the splitter pattern matches but the individual flag then errors on processing. Additionally, adding consistent spacing after `?*)` realigns comments with other `case` branches for better visual consistency.

---
*/ai/scripts/File/whichx | session fc90ab71 | 2026-03-11*
<!-- hash: 08be0e7b0c8a19f65f7d9e19b72b9d60 -->
<!-- general: true -->
