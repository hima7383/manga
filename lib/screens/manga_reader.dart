import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaleya/providers/readerprovidor.dart';
import '../../models/chapter.dart';

enum ReaderMode { paged, vertical }

class ReaderScreen extends ConsumerStatefulWidget {
  final Chapter chapter;
  final String mangaTitle;
  final List<Chapter>? chapterList;

  const ReaderScreen({
    super.key,
    required this.chapter,
    required this.mangaTitle,
    this.chapterList,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  ReaderMode _readerMode = ReaderMode.paged;
  int _currentPage = 0;
  bool _showControls = true;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.chapter.isRead ? widget.chapter.pages.length - 1 : 0;
    _pageController.addListener(_updateCurrentPage);
    _scrollController.addListener(_updateVerticalPosition);
  }

  @override
  void dispose() {
    _pageController.removeListener(_updateCurrentPage);
    _scrollController.removeListener(_updateVerticalPosition);
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateCurrentPage() {
    final newPage = _pageController.page?.round() ?? 0;
    if (newPage != _currentPage) {
      setState(() => _currentPage = newPage);
      _markAsReadIfNeeded();
    }
  }

  void _updateVerticalPosition() {
    final position = _scrollController.position.pixels;
    final pageHeight = MediaQuery.of(context).size.height;
    final newPage = (position / pageHeight).round();
    if (newPage != _currentPage) {
      setState(() => _currentPage = newPage);
      _markAsReadIfNeeded();
    }
  }

  void _markAsReadIfNeeded() {
    if (_currentPage == widget.chapter.pages.length - 1) {
      ref.read(readerProvider.notifier).markAsRead(widget.chapter);
    }
  }

  void _jumpToPage(int page) {
    if (_readerMode == ReaderMode.paged) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.animateTo(
        page * MediaQuery.of(context).size.height,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main reader content
          GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
            child: _readerMode == ReaderMode.paged
                ? _buildPagedReader()
                : _buildVerticalReader(),
          ),

          // Controls overlay
          if (_showControls || _isLoadingImage) _buildReaderControls(),
        ],
      ),
    );
  }

  Widget _buildPagedReader() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.chapter.pages.length,
      onPageChanged: (index) => setState(() => _currentPage = index),
      itemBuilder: (context, index) {
        return InteractiveViewer(
            panEnabled: true,
            minScale: 1.0,
            maxScale: 3.0,
            child: SingleChildScrollView(
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.chapter.pages[index],
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.of(context).size.width,
                  progressIndicatorBuilder: (context, url, progress) {
                    _isLoadingImage = progress.progress != 1.0;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.progress,
                      ),
                    );
                  },
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    color: Colors.white,
                  ),
                ),
              ),
            ));
      },
    );
  }

  Widget _buildVerticalReader() {
    return ListView.builder(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      itemCount: widget.chapter.pages.length,
      itemBuilder: (context, index) {
        return SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 3.0,
                child: CachedNetworkImage(
                  imageUrl: widget.chapter.pages[index],
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width, // fits screen width
                  progressIndicatorBuilder: (context, url, progress) {
                    _isLoadingImage = progress.progress != 1.0;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.progress,
                      ),
                    );
                  },
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error, color: Colors.white),
                  ),
                ),
              ),
            ));
      },
    );
  }

  Widget _buildReaderControls() {
    return Column(
      children: [
        // Top app bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '${widget.mangaTitle} - ${widget.chapter.title}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _readerMode == ReaderMode.paged
                      ? Icons.swap_vert
                      : Icons.swap_horiz,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _readerMode = _readerMode == ReaderMode.paged
                        ? ReaderMode.vertical
                        : ReaderMode.paged;
                    // Reset to current page when switching modes
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _jumpToPage(_currentPage);
                    });
                  });
                },
                tooltip: _readerMode == ReaderMode.paged
                    ? 'Switch to vertical mode'
                    : 'Switch to paged mode',
              ),
            ],
          ),
        ),

        const Spacer(),

        // Bottom controls
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentPage + 1) / widget.chapter.pages.length,
                backgroundColor: Colors.grey[800],
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),

              // Page navigation
              Row(
                children: [
                  // Previous chapter button
                  if (widget.chapterList != null &&
                      widget.chapterList!.isNotEmpty &&
                      _currentPage == 0)
                    IconButton(
                      icon:
                          const Icon(Icons.skip_previous, color: Colors.white),
                      onPressed: () => _navigateToAdjacentChapter(-1),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: _currentPage > 0
                          ? () => _jumpToPage(_currentPage - 1)
                          : null,
                    ),

                  Expanded(
                    child: Center(
                      child: Text(
                        'Page ${_currentPage + 1}/${widget.chapter.pages.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  // Next chapter button
                  if (widget.chapterList != null &&
                      widget.chapterList!.isNotEmpty &&
                      _currentPage == widget.chapter.pages.length - 1)
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: () => _navigateToAdjacentChapter(1),
                    )
                  else
                    IconButton(
                      icon:
                          const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: _currentPage < widget.chapter.pages.length - 1
                          ? () => _jumpToPage(_currentPage + 1)
                          : null,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToAdjacentChapter(int direction) {
    if (widget.chapterList == null) return;

    final currentIndex = widget.chapterList!.indexWhere(
      (c) => c.id == widget.chapter.id,
    );

    if (currentIndex == -1) return;

    final newIndex = currentIndex + direction;
    if (newIndex >= 0 && newIndex < widget.chapterList!.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReaderScreen(
            chapter: widget.chapterList![newIndex],
            mangaTitle: widget.mangaTitle,
            chapterList: widget.chapterList,
          ),
        ),
      );
    }
  }
}
