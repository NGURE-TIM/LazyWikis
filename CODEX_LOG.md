---
## [feature/mediawiki-toc-headings] — 2026-02-11
**Task:** Implement MediaWiki-compliant section headings and TOC handling in wikitext generation so step sections are navigable and TOC-friendly.
**Status:** COMPLETE
**Files Modified:**
- lib/data/services/wikitext_generator.dart — added `includeToc` option to `generate`, added explicit `== Introduction ==` section heading, enforced section heading levels (`==` top-level, `===` nested), and sanitized heading text to plain text before heading wrapping.
- lib/utils/wikitext_renderer.dart — improved heading parsing with a stricter heading regex and adjusted heading typography/padding so level differences are visually clearer in preview.
**Files Created:**
- CODEX_LOG.md — appended this task log entry.
**Decisions Made:**
- Kept TOC emission gated by both `includeToc` and `guide.hasTableOfContents` to preserve existing output behavior unless TOC is explicitly configured in the guide.
- Capped nested step headings to level 3 (`===`) for all non-top-level steps to match requested hierarchy.
- Removed heading styling markup from generated heading titles by sanitizing raw text before wrapping.
**Follow-up Issues Found:**
- Local validation command `flutter test test/widget_test.dart` could not run in this environment because `flutter` is not installed (`flutter: command not found`).
---
