import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangaleya/providers/manga_provider.dart';
import 'package:mangaleya/providers/provider.dart';
import '../../models/manga.dart';

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(
    mangaScraper: ref.watch(mangaScraperProvider),
  );
});

class SearchNotifier extends StateNotifier<SearchState> {
  final MangaScraper mangaScraper;

  SearchNotifier({
    required this.mangaScraper,
  }) : super(SearchState.initial());

  Future<void> searchManga(String query) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final results = await mangaScraper.searchManga(query);
      state = state.copyWith(
        searchResults: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(searchResults: []);
  }
}

class SearchState {
  final List<Manga> searchResults;
  final bool isLoading;
  final String? error;

  SearchState({
    required this.searchResults,
    required this.isLoading,
    this.error,
  });

  factory SearchState.initial() => SearchState(
    searchResults: [],
    isLoading: false,
  );

  SearchState copyWith({
    List<Manga>? searchResults,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}