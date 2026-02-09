import 'dart:convert';
import 'package:lazywikis/data/models/guide.dart';
import 'package:lazywikis/data/models/step.dart';
import 'package:lazywikis/data/models/step_content.dart';
import 'package:lazywikis/data/models/image_data.dart';
import 'package:lazywikis/data/services/wikitext_generator.dart';
import 'package:lazywikis/data/services/download_service.dart';
import 'package:lazywikis/data/services/annotation_baker.dart';
import 'package:archive/archive.dart';

class ExportService {
  final WikiTextGenerator _generator = WikiTextGenerator();
  final DownloadService _downloadService = DownloadService.instance;

  void exportWikiText(Guide guide) {
    final text = _generator.generate(guide);
    final filename = '${_sanitizeFilename(guide.title ?? "guide")}.txt';

    _downloadService.downloadFile(filename, utf8.encode(text), 'text/plain');
  }

  Future<void> exportZip(Guide guide) async {
    final archive = Archive();

    // 1. Collect images and prepare modified guide for export
    final imageMap = <String, List<int>>{}; // filename -> bytes
    final guideForExport = await _prepareGuideForZip(guide, imageMap);

    // 2. Add WikiText
    final text = _generator.generate(guideForExport);
    archive.addFile(
      ArchiveFile('guide.txt', utf8.encode(text).length, utf8.encode(text)),
    );

    // 3. Add Images
    for (var entry in imageMap.entries) {
      archive.addFile(
        ArchiveFile('images/${entry.key}', entry.value.length, entry.value),
      );
    }

    // 4. Compress
    final zipEncoder = ZipEncoder();
    final zipBytes = zipEncoder.encode(archive);

    if (zipBytes != null) {
      final filename =
          '${_sanitizeFilename(guide.title ?? "guide")}-bundle.zip';
      _downloadService.downloadFile(filename, zipBytes, 'application/zip');
    }
  }

  /// Creates a copy of the guide with modified image steps to point to local files
  Future<Guide> _prepareGuideForZip(
    Guide guide,
    Map<String, List<int>> imageMap,
  ) async {
    // We need to clone the guide structure because we are modifying steps
    // Since Guide is complex, we'll iterate and rebuild
    final newSteps = <Step>[];

    for (var step in guide.steps) {
      newSteps.add(await _processStepForZip(step, imageMap));
    }

    // Process introduction if exists
    final introduction = guide.introduction != null
        ? await _processStepForZip(guide.introduction!, imageMap)
        : null;

    return Guide(
      id: guide.id,
      title: guide.title,
      steps: newSteps,
      introduction: introduction,
      categories: guide.categories,
      metadata: guide.metadata,
      hasTableOfContents: guide.hasTableOfContents,
      createdAt: guide.createdAt,
      updatedAt: guide.updatedAt,
    );
  }

  Future<Step> _processStepForZip(
    Step step,
    Map<String, List<int>> imageMap,
  ) async {
    final newContents = <StepContent>[];

    for (var content in step.contents) {
      if (content.type == StepContentType.image && content.image != null) {
        // Handle Image
        var bytes = base64Decode(content.image!.base64Data);

        // Bake Annotations if present
        if (content.image!.annotations != null &&
            content.image!.annotations!.isNotEmpty) {
          try {
            bytes = await AnnotationBaker.bake(
              bytes,
              content.image!.annotations!,
            );
          } catch (e) {
            // Fallback to original if baking fails
            print('Failed to bake annotations: $e');
          }
        }

        final ext = _getExtension(content.image!.mimeType);
        final filename = 'step-${step.order}-${content.id}.$ext';

        imageMap[filename] = bytes;

        // Replace content with a "Text" content containing the Wiki markup
        newContents.add(
          StepContent.text(
            content: '[[File:$filename|${content.caption ?? ""}]]',
          ),
        );
      } else {
        newContents.add(content);
      }
    }

    // Handle legacy step.image if contents was empty and using legacy fields
    ImageData? legacyImage = step.image;
    List<StepContent> finalContents = List.from(newContents);

    if (step.contents.isEmpty && legacyImage != null) {
      var bytes = base64Decode(legacyImage.base64Data);

      // Bake Legacy Annotations
      if (legacyImage.annotations != null &&
          legacyImage.annotations!.isNotEmpty) {
        try {
          bytes = await AnnotationBaker.bake(bytes, legacyImage.annotations!);
        } catch (e) {
          print('Failed to bake legacy annotations: $e');
        }
      }

      final ext = _getExtension(legacyImage.mimeType);
      final filename = 'step-${step.order}-legacy.$ext';
      imageMap[filename] = bytes;
      finalContents.add(
        StepContent.text(
          content: '[[File:$filename|${step.imageCaption ?? ""}]]',
        ),
      );
    }

    return step.copyWith(contents: finalContents, image: null);
  }

  String _getExtension(String mime) {
    switch (mime) {
      case 'image/png':
        return 'png';
      case 'image/jpeg':
        return 'jpg';
      case 'image/gif':
        return 'gif';
      default:
        return 'png';
    }
  }

  String _sanitizeFilename(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').replaceAll(' ', '_');
  }
}
