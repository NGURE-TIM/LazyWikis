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
## fix/wikitext-formatting-and-preview — 2026-02-11
**Task:** Fix wikitext generator to output valid MediaWiki markup and update preview to match
**Status:** PARTIAL
**Files Modified:**
- lib/utils/quill_to_wikitext.dart — rewrote Delta conversion to line-aware MediaWiki output for headings, bullet/numbered lists (including nested markers), indentation (`:`), syntaxhighlight blocks, links, color span formatting, and bold/italic combinations.
- lib/utils/wikitext_renderer.dart — upgraded preview parser/renderer to visually render MediaWiki constructs from generated wikitext (headers, unordered/ordered lists, indentation, external/internal links, color spans, bold/italic, TOC marker, and code/pre blocks) without showing raw symbols in rendered mode.
**Files Created:**
- lib/utils/link_opener.dart — conditional link opener API used by preview for external links.
- lib/utils/link_opener_stub.dart — non-web no-op opener.
- lib/utils/link_opener_web.dart — web opener implementation using `window.open(..., '_blank')`.
**Decisions Made:**
- Implemented line-based conversion in `QuillToWikiText` because Quill list/indent/header semantics are encoded on newline operations and cannot be emitted correctly with naive per-op formatting.
- Kept generator structure output (title/step/image/command scaffolding) unchanged and focused formatting correctness in Quill conversion + preview parser to avoid regressions.
- Added basic auto-wrapping of bare external URLs into `[url url]` to reduce chance of non-clickable raw URLs in exported content.
- Used conditional `dart:html` link opener for web preview link clicks instead of introducing a new package dependency.
**Follow-up Issues Found:**
- Could not run full Flutter app/runtime validation in this environment (`flutter` command unavailable earlier in session).
- `dart:html` is deprecated (analyzer info); future migration to `package:web` is recommended.
