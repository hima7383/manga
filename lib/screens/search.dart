import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangaleya/providers/searchprovider.dart';
import 'package:mangaleya/screens/mangadetails.dart';
import '../../models/manga.dart';


class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search manga...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).clearSearch();
              },
            ),
          ),
          onSubmitted: (query) {
            if (query.trim().isNotEmpty) {
              ref.read(searchProvider.notifier).searchManga(query);
            }
          },
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.error != null) {
      return Center(
        child: Text(
          state.error!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }
    
    if (state.searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(child: Text('No results found'));
    }
    
    if (state.searchResults.isEmpty) {
      return const Center(child: Text('Search for manga'));
    }
    
    return ListView.builder(
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final manga = state.searchResults[index];
        return ListTile(
          leading: CachedNetworkImage(
            imageUrl: manga.coverUrl,
            width: 50,
            height: 70,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[300],
            ),
          ),
          title: Text(manga.title),
          subtitle: manga.latestChapter != null
              ? Text('Ch. ${manga.latestChapter}')
              : null,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MangaScreen(manga: manga),
            ),
          ),
        );
      },
    );
  }
}