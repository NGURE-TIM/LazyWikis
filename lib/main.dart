import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/wikitext_generator.dart';
import 'data/services/image_handler_service.dart';
import 'data/repositories/guide_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize async services
  final localStorage = LocalStorageService();
  await localStorage.init();

  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider<LocalStorageService>.value(value: localStorage),
        Provider<WikiTextGenerator>(create: (_) => WikiTextGenerator()),
        Provider<ImageHandlerService>(create: (_) => ImageHandlerService()),
        Provider<GuideRepository>(create: (context) => GuideRepository(context.read())),
      ],
      child: const LazyWikisApp(),
    ),
  );
}
