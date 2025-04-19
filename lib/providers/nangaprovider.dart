import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangaleya/providers/cache.dart';
import 'package:mangaleya/providers/manga_provider.dart';
import 'package:mangaleya/providers/provider.dart';
import '../../models/manga.dart';
import '../../models/chapter.dart';


final mangaProvider = StateNotifierProvider<MangaNotifier, MangaState>((ref) {
  return MangaNotifier(
    mangaScraper: ref.watch(mangaScraperProvider),
    cacheService: ref.watch(cacheServiceProvider),
  );
});

class MangaNotifier extends StateNotifier<MangaState> {
  final MangaScraper mangaScraper;
  final CacheService cacheService;

  MangaNotifier({
    required this.mangaScraper,
    required this.cacheService,
  }) : super(MangaState.initial());

  Future<void> loadMangaDetails(String url) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final manga = await mangaScraper.fetchMangaDetails(url);
      
      final isBookmarked = cacheService.isBookmarked(manga.id);
      state = state.copyWith(
        manga: manga.copyWith(isBookmarked: isBookmarked),
        isLoading: false,
      );
      
      await _loadChapters();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> _loadChapters() async {
    if (state.manga == null || 
        (state.manga!.chapters?.isNotEmpty ?? false)) return;
    
    try {
      state = state.copyWith(isLoadingChapters: true, error: null);
      final manga = state.manga!;
      
      // If chapters are already loaded but without pages
      if (manga.chapters != null) {
        state = state.copyWith(isLoadingChapters: false);
        return;
      }
      
      // Otherwise load from scratch
      final updatedManga = await mangaScraper.fetchMangaDetails(manga.url);
      state = state.copyWith(
        manga: updatedManga.copyWith(isBookmarked: manga.isBookmarked),
        isLoadingChapters: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoadingChapters: false,
      );
    }
  }

  Future<Chapter?> loadChapterPages(String url) async {
    try {
      state = state.copyWith(isLoadingChapters: true, error: null);
      final chapter = await mangaScraper.fetchChapterPages(url);
      state = state.copyWith(isLoadingChapters: false);
      return chapter;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoadingChapters: false,
      );
      return null;
    }
  }

  void toggleBookmark(Manga manga) {
    final updatedManga = manga.copyWith(isBookmarked: !manga.isBookmarked);
    
    if (updatedManga.isBookmarked) {
      cacheService.addBookmark(updatedManga);
    } else {
      cacheService.removeBookmark(updatedManga.id);
    }
    
    state = state.copyWith(manga: updatedManga);
  }
}

class MangaState {
  final Manga? manga;
  final bool isLoading;
  final bool isLoadingChapters;
  final String? error;

  MangaState({
    this.manga,
    required this.isLoading,
    required this.isLoadingChapters,
    this.error,
  });

  factory MangaState.initial() => MangaState(
    isLoading: false,
    isLoadingChapters: false,
  );

  MangaState copyWith({
    Manga? manga,
    bool? isLoading,
    bool? isLoadingChapters,
    String? error,
  }) {
    return MangaState(
      manga: manga ?? this.manga,
      isLoading: isLoading ?? this.isLoading,
      isLoadingChapters: isLoadingChapters ?? this.isLoadingChapters,
      error: error ?? this.error,
    );
  }
}