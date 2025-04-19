import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangaleya/providers/cache.dart';
import 'package:mangaleya/providers/provider.dart';
import '../../models/chapter.dart';

final readerProvider = StateNotifierProvider<ReaderNotifier, ReaderState>((ref) {
  return ReaderNotifier(
    cacheService: ref.watch(cacheServiceProvider),
  );
});

class ReaderNotifier extends StateNotifier<ReaderState> {
  final CacheService cacheService;

  ReaderNotifier({
    required this.cacheService,
  }) : super(ReaderState.initial());

  void markAsRead(Chapter chapter) {
    final updatedChapter = chapter.copyWith(
      isRead: true,
    );
    // Here you would typically update this in your database
    // For now we just update the state
    state = state.copyWith(lastReadChapter: updatedChapter);
  }
}

class ReaderState {
  final Chapter? lastReadChapter;

  ReaderState({
    this.lastReadChapter,
  });

  factory ReaderState.initial() => ReaderState();

  ReaderState copyWith({
    Chapter? lastReadChapter,
  }) {
    return ReaderState(
      lastReadChapter: lastReadChapter ?? this.lastReadChapter,
    );
  }
}