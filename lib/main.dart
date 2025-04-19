import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mangaleya/screens/bookmarks_screen.dart';
import 'models/manga.dart';
import 'models/chapter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MangaAdapter());
  Hive.registerAdapter(ChapterAdapter());
  await Hive.openBox('app_preferences');
  await Hive.openBox('bookmarks');
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(const MangaReaderApp());
}