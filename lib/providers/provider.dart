import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangaleya/providers/cache.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mangaleya/providers/manga_provider.dart';

final mangaScraperProvider = Provider((ref) => MangaScraper());

final cacheServiceProvider = Provider((ref) {
  return CacheService(
    Hive.box('app_preferences'),
    Hive.box('bookmarks'),
  );
});