# LazyWikis

LazyWikis is a Flutter web app for building MediaWiki-ready installation guides.
It lets you compose guides as structured steps (text, commands, screenshots with annotations), preview generated wikitext, and export either plain wikitext or a ZIP bundle.

## 2-Minute Quick Start

1. Build and run with Docker:
```bash
docker build -t lazywikis .
docker run --rm -p 8080:80 lazywikis
```
2. Open `http://localhost:8080`
3. Create a guide, add one step, add a command block, then export `WikiText (.txt)`

## What You Can Do

- Create a guide with an introduction and ordered steps
- Add content blocks per step:
  - Rich text
  - Command + optional output
  - Screenshot + caption + annotations (arrow/circle/rectangle)
- Generate MediaWiki-compatible wikitext with:
  - Proper section headings
  - TOC support
  - Command and output labels
  - Centered, wide image markup
- Export:
  - `guide.txt` (wikitext)
  - ZIP bundle (`guide.txt` + `images/`) with baked annotations

## Core Workflow (New Users)

1. Open dashboard and create a guide.
2. Add or rename steps from the left sidebar.
3. Select a step and add text/command/image blocks in the editor.
4. Use the right preview panel:
   - `Rendered` for a visual approximation
   - `Raw` for exact generated wikitext
5. Export:
   - `WikiText (.txt)` for copy/paste
   - `Bundle (.zip)` when images are included

## Quick Start

### Option 1: Docker

```bash
docker build -t lazywikis .
docker run --rm -p 8080:80 lazywikis
```

Open `http://localhost:8080`.

### Option 2: Flutter (local dev)

Prerequisites:
- Flutter SDK (project has been used with Flutter 3.35.x)
- Chrome (or another supported web browser)

```bash
flutter pub get
flutter run -d chrome
```

## Export Behavior

### Wikitext generation

- Guide title uses level-1 heading: `= Guide Title =`
- Steps use section headings for MediaWiki TOC
- Command blocks are emitted as:

```wikitext
;Command:
<pre>
...
</pre>

;Output:
<pre>
...
</pre>
```

- Images are emitted as centered/wide MediaWiki file tags

### Image filenames

Image filenames are generated consistently for both wikitext and ZIP export.

Priority:
1. Caption-based filename (sanitized)
2. Fallback: `guide_step{n}_{m}.ext`

This prevents mismatches between `[[File:...]]` references and actual exported files.

### Annotation baking

During ZIP export, image annotations are baked into image bytes.
Coordinates are normalized to avoid positional shifts between editor preview and exported files.

## Project Structure

- `lib/data/models/` domain models (`Guide`, `Step`, `StepContent`, image + annotation models)
- `lib/data/services/` generation/export/annotation/image services
- `lib/ui/` dashboard/editor/view widgets
- `lib/utils/` conversion/rendering/helpers (wikitext renderer, quill conversion, filename helpers)
- `lib/routing/` app router (`go_router`)
- `lib/config/` theme and constants

## Known Constraints

- Download service is web-first; non-web download is stubbed.
- Wikitext renderer is a preview approximation, not a full MediaWiki engine.
- Existing test coverage is minimal.

## Development Notes

Useful commands:

```bash
dart format lib test
flutter analyze
flutter test
```

## Contributor Guide

### Architecture at a Glance

- UI layer (`lib/ui/`): screen/widgets + editor interactions
- ViewModel layer (`lib/ui/guide_editor/guide_editor_viewmodel.dart`): state transitions and save flow
- Data/services layer (`lib/data/services/`): generation, export, image/annotation handling
- Models (`lib/data/models/`): serializable guide/step/content/image domain objects

### State Flow (Editor)

1. User edits content in a block editor widget.
2. Block emits updated `StepContent`.
3. Step editor updates the selected `Step`.
4. ViewModel updates guide state and regenerates wikitext.
5. Preview panel re-renders from the generated wikitext string.
6. Save/export uses the same guide state and generated output pipeline.

### How to Add a New Content Block Type

1. Add new enum value in `StepContentType` (`lib/data/models/step_content.dart`).
2. Add fields/factory/copyWith support in `StepContent`.
3. Update JSON serialization (and generated `*.g.dart` if needed).
4. Add editor widget under `lib/ui/guide_editor/widgets/editors/`.
5. Wire it in `StepEditorPanel._buildEditorForContent(...)`.
6. Update `WikiTextGenerator` to emit valid MediaWiki output.
7. Update `WikiTextRenderer` so rendered preview matches emitted wikitext.
8. Validate export path if the block writes files/resources.

## License

This project is open source and licensed under the MIT License.
See `LICENSE` for the full text.
