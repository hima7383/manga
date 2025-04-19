import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaleya/providers/readerprovidor.dart';
import '../../models/chapter.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final Chapter chapter;
  final String mangaTitle;

  const ReaderScreen({
    super.key,
    required this.chapter,
    required this.mangaTitle,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showControls = true;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.chapter.isRead 
        ? widget.chapter.pages.length - 1 
        : 0;
    _pageController.addListener(_updateCurrentPage);
  }

  @override
  void dispose() {
    _pageController.removeListener(_updateCurrentPage);
    _pageController.dispose();
    super.dispose();
  }

  void _updateCurrentPage() {
    final newPage = _pageController.page?.round() ?? 0;
    if (newPage != _currentPage) {
      setState(() => _currentPage = newPage);
      
      // Mark as read if we reach the last page
      if (newPage == widget.chapter.pages.length - 1) {
        ref.read(readerProvider.notifier).markAsRead(widget.chapter);
      }
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
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.chapter.pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  panEnabled: true,
                  minScale: 1.0,
                  maxScale: 3.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.chapter.pages[index],
                      fit: BoxFit.contain,
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
                );
              },
            ),
          ),
          
          // Controls overlay
          if (_showControls || _isLoadingImage) _buildReaderControls(),
        ],
      ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 32,
          ),
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
              
              // Page info and navigation
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: _currentPage > 0
                        ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
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
                  
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: _currentPage < widget.chapter.pages.length - 1
                        ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
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
}