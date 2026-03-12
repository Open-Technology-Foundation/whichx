# Documentation Accuracy Doesn't Replace Code Comments

Well-maintained help text and exit codes that match implementation are valuable, but they document *what* the code does, not *why*. Explanatory comments for non-obvious patterns—like POSIX empty-PATH semantics, combined-option splitting, and function export behavior—serve a different purpose: they prevent future maintainers from misinterpreting or accidentally breaking subtle logic that appears redundant or counterintuitive on first read. Help text accuracy is a prerequisite for reliability; internal comments explain the reasoning behind non-obvious design choices.

---
*/ai/scripts/File/whichx | session d626b99e | 2026-03-12*
<!-- hash: 53ecec630658024b30dce1e8d71429ed -->
<!-- general: true -->
