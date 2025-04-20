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
  late Manga _currentManga;
  final _scrollController = ScrollController();
  bool _isInitialLoad = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentManga = widget.manga;
    _loadManga();
  }

  @override
  void didUpdateWidget(MangaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.manga.url != oldWidget.manga.url) {
      _currentManga = widget.manga;
      _loadManga();
    }
  }

  void _loadManga() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(mangaProvider.notifier).reset();
        ref.read(mangaProvider.notifier).loadMangaDetails(_currentManga.url);
        setState(() {
          _isInitialLoad = false;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(mangaProvider.notifier).reset();
      }
    });
    _scrollController.dispose();
    super.dispose();
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
          mangaTitle: _currentManga.title,
        ),
      ),
    ).then((_) {
      // Refresh when returning from reader
      if (mounted) {
        ref.read(mangaProvider.notifier).loadMangaDetails(_currentManga.url);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mangaProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isInitialLoad || (state.isLoading && state.manga == null)) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: colorScheme.primary,
          ),
        ),
      );
    }

    final displayManga = state.manga ?? _currentManga;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            floating: true,
            snap: false,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                displayManga.title,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: colorScheme.surface.withOpacity(0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: displayManga.coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: colorScheme.surfaceVariant,
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.broken_image,
                      color: colorScheme.error,
                    ),
                  ),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          colorScheme.surface.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  displayManga.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: colorScheme.onSurface,
                ),
                onPressed: () => ref
                    .read(mangaProvider.notifier)
                    .toggleBookmark(displayManga),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metadata chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (displayManga.rating > 0)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 18,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    displayManga.rating.toStringAsFixed(1),
                                    style: textTheme.labelLarge,
                                  ),
                                ],
                              ),
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              backgroundColor: colorScheme.surfaceVariant, onSelected: (bool value) {  },
                            ),
                          ),
                        if (displayManga.status != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                displayManga.status!,
                                style: textTheme.labelLarge,
                              ),
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              backgroundColor: colorScheme.surfaceVariant, onSelected: (bool value) {  },
                            ),
                          ),
                        if (displayManga.author != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                'By ${displayManga.author!}',
                                style: textTheme.labelLarge,
                              ),
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              backgroundColor: colorScheme.surfaceVariant, onSelected: (bool value) {  },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Alternative titles
                  if (displayManga.alternativeNames?.isNotEmpty ?? false)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Also known as:',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          displayManga.alternativeNames!.join(', '),
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  // Description with expand/collapse
                  if (displayManga.description != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Description',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (displayManga.description!.length > 150)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                  });
                                },
                                child: Text(
                                  _isExpanded ? 'Show less' : 'Show more',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: _isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: Text(
                            displayManga.description!.length > 150
                                ? '${displayManga.description!.substring(0, 150)}...'
                                : displayManga.description!,
                            style: textTheme.bodyMedium,
                          ),
                          secondChild: Text(
                            displayManga.description!,
                            style: textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  // Genres
                  if (displayManga.genres?.isNotEmpty ?? false)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Genres',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: displayManga.genres!
                              .map(
                                (genre) => ActionChip(
                                  label: Text(genre),
                                  backgroundColor: colorScheme.surfaceVariant,
                                  shape: StadiumBorder(
                                    side: BorderSide(
                                      color: colorScheme.outlineVariant,
                                    ),
                                  ),
                                  onPressed: () {},
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                ],
              ),
            ),
          ),
          // Chapters header
          SliverPersistentHeader(
            pinned: true,
            delegate: _ChapterHeaderDelegate(
              colorScheme: colorScheme,
              chapterCount: displayManga.chapters?.length ?? 0,
            ),
          ),
          // Chapters list
          if (state.isLoadingChapters)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            )
          else if (displayManga.chapters?.isNotEmpty ?? false)
            SliverList.separated(
              itemCount: displayManga.chapters!.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final chapter = displayManga.chapters![index];
                return Material(
                  color: colorScheme.surface,
                  child: InkWell(
                    onTap: () => _openChapter(chapter),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chapter.title,
                                  style: textTheme.bodyLarge,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (chapter.date != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      chapter.date!,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          if (state.error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: colorScheme.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _loadManga,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChapterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ColorScheme colorScheme;
  final int chapterCount;

  _ChapterHeaderDelegate({
    required this.colorScheme,
    required this.chapterCount,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Chapters',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text(
              chapterCount.toString(),
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            backgroundColor: colorScheme.secondaryContainer,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}