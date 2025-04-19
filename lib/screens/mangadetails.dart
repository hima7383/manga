import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaleya/providers/nangaprovider.dart';
import 'package:mangaleya/screens/manga_reader.dart';
import '../../models/manga.dart';
import '../../models/chapter.dart';

class MangaScreen extends ConsumerStatefulWidget {
  final Manga manga;

  const MangaScreen({super.key, required this.manga});

  @override
  ConsumerState<MangaScreen> createState() => _MangaScreenState();
}

class _MangaScreenState extends ConsumerState<MangaScreen> {
  late Manga _manga;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _manga = widget.manga;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mangaProvider.notifier).loadMangaDetails(_manga.url);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mangaProvider);

    if (state.manga != null) {
      _manga = state.manga!;
    }

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _manga.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: CachedNetworkImage(
                imageUrl: _manga.coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _manga.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
                onPressed: () =>
                    ref.read(mangaProvider.notifier).toggleBookmark(_manga),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating and metadata
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (_manga.rating > 0)
                        Chip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber),
                              Text(' ${_manga.rating.toStringAsFixed(1)}'),
                            ],
                          ),
                        ),
                      if (_manga.status != null)
                        Chip(label: Text(_manga.status!)),
                      if (_manga.author != null)
                        Chip(label: Text('Author: ${_manga.author!}')),
                      if (_manga.artist != null &&
                          _manga.artist != _manga.author)
                        Chip(label: Text('Artist: ${_manga.artist!}')),
                    ],
                  ),

// Alternative names
                  if (_manga.alternativeNames?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Also known as:',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            _manga.alternativeNames!.join(', '),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),

// Description
                  if (_manga.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(_manga.description!),
                        ],
                      ),
                    ),

// Genres
                  if (_manga.genres?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Genres',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _manga.genres!
                                .map((genre) => Chip(label: Text(genre)))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Chapters list
          if (state.isLoadingChapters)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_manga.chapters?.isNotEmpty ?? false)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final chapter = _manga.chapters![index];
                  return ListTile(
                    title: Text(chapter.title),
                    subtitle: chapter.date != null ? Text(chapter.date!) : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openChapter(chapter),
                  );
                },
                childCount: _manga.chapters!.length,
              ),
            ),

          if (state.error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    state.error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openChapter(Chapter chapter) async {
    if (chapter.pages.isEmpty) {
      final loadedChapter =
          await ref.read(mangaProvider.notifier).loadChapterPages(chapter.url);
      if (loadedChapter != null && mounted) {
        _navigateToReader(loadedChapter);
      }
    } else {
      _navigateToReader(chapter);
    }
  }

  void _navigateToReader(Chapter chapter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(
          chapter: chapter,
          mangaTitle: _manga.title,
        ),
      ),
    );
  }
}
