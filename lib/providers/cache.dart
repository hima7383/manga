import 'package:hive/hive.dart';
import '../models/manga.dart';

class CacheService {
  final Box _prefsBox;
  final Box _bookmarksBox;

  CacheService(this._prefsBox, this._bookmarksBox);

  // Preferences
  bool get isDarkMode => _prefsBox.get('isDarkMode', defaultValue: false);
  set isDarkMode(bool value) => _prefsBox.put('isDarkMode', value);

  String get readerMode => _prefsBox.get('readerMode', defaultValue: 'paged');
  set readerMode(String value) => _prefsBox.put('readerMode', value);

  // Bookmarks
  List<Manga> get bookmarks {
    return _bookmarksBox.values.map((e) => e as Manga).toList();
  }

  bool isBookmarked(String mangaId) {
    return _bookmarksBox.containsKey(mangaId);
  }

  void addBookmark(Manga manga) {
    _bookmarksBox.put(manga.id, manga.copyWith(isBookmarked: true));
  }

  void removeBookmark(String mangaId) {
    _bookmarksBox.delete(mangaId);
  }

  void clearCache() {
    _prefsBox.clear();
    _bookmarksBox.clear();
  }
}