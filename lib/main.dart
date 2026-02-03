import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Services and repositories will be added in Phase 1
        // ViewModels will be added in Phase 2+
      ],
      child: const LazyWikisApp(),
    ),
  );
}
