import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangaleya/providers/cache.dart';
import 'package:mangaleya/providers/manga_provider.dart';
import 'package:mangaleya/providers/provider.dart';
import '../../models/manga.dart';


final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(
    mangaScraper: ref.watch(mangaScraperProvider),
    cacheService: ref.watch(cacheServiceProvider),
  );
});

class HomeNotifier extends StateNotifier<HomeState> {
  final MangaScraper mangaScraper;
  final CacheService cacheService;
  int _currentPage = 1;
  bool _hasMore = true;

  HomeNotifier({
    required this.mangaScraper,
    required this.cacheService,
  }) : super(HomeState.initial());

  Future<void> loadInitialData() async {
    try {
      state = state.copyWith(
        isLoading: true,
        isLoadingFeatured: true,
        error: null,
      );
      
      final [featured, popular] = await Future.wait([
        mangaScraper.fetchPopularManga(page: 1),
        mangaScraper.fetchPopularManga(page: 1),
      ]);
      
      final bookmarkedIds = cacheService.bookmarks.map((m) => m.id).toSet();
      final mangaWithBookmarks = popular.map((m) => m.copyWith(
        isBookmarked: bookmarkedIds.contains(m.id),
      )).toList();
      
      state = state.copyWith(
        manga: mangaWithBookmarks,
        featuredManga: featured.take(5).toList(),
        isLoading: false,
        isLoadingFeatured: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isLoadingFeatured: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoadingMore) return;
    
    try {
      state = state.copyWith(isLoadingMore: true);
      _currentPage++;
      
      final newManga = await mangaScraper.fetchPopularManga(page: _currentPage);
      if (newManga.isEmpty) {
        _hasMore = false;
      } else {
        final bookmarkedIds = cacheService.bookmarks.map((m) => m.id).toSet();
        final mangaWithBookmarks = newManga.map((m) => m.copyWith(
          isBookmarked: bookmarkedIds.contains(m.id),
        )).toList();
        
        state = state.copyWith(
          manga: [...state.manga, ...mangaWithBookmarks],
          isLoadingMore: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoadingMore: false,
      );
      _currentPage--; // Revert page increment on error
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    await loadInitialData();
  }

  void toggleBookmark(Manga manga) {
    final updatedManga = manga.copyWith(isBookmarked: !manga.isBookmarked);
    
    if (updatedManga.isBookmarked) {
      cacheService.addBookmark(updatedManga);
    } else {
      cacheService.removeBookmark(updatedManga.id);
    }
    
    state = state.copyWith(
      manga: state.manga.map((m) => m.id == updatedManga.id ? updatedManga : m).toList(),
      featuredManga: state.featuredManga.map((m) => 
        m.id == updatedManga.id ? updatedManga : m).toList(),
    );
  }
}

class HomeState {
  final List<Manga> manga;
  final List<Manga> featuredManga;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isLoadingFeatured;
  final String? error;

  HomeState({
    required this.manga,
    required this.featuredManga,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isLoadingFeatured,
    this.error,
  });

  factory HomeState.initial() => HomeState(
    manga: [],
    featuredManga: [],
    isLoading: false,
    isLoadingMore: false,
    isLoadingFeatured: false,
  );

  HomeState copyWith({
    List<Manga>? manga,
    List<Manga>? featuredManga,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isLoadingFeatured,
    String? error,
  }) {
    return HomeState(
      manga: manga ?? this.manga,
      featuredManga: featuredManga ?? this.featuredManga,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingFeatured: isLoadingFeatured ?? this.isLoadingFeatured,
      error: error ?? this.error,
    );
  }
}