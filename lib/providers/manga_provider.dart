import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import '../models/manga.dart';
import '../models/chapter.dart';

class MangaScraper {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://lekmanga.net',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<Manga>> fetchPopularManga({int page = 1}) async {
    try {
      final response = await _dio.get('/page/$page/');
      final document = parser.parse(response.data);

      final mangaElements = document
          .querySelectorAll('.page-listing-item .page-item-detail.manga');
      return mangaElements
          .map((element) => _parseMangaElement(element))
          .toList();
    } catch (e) {
      throw Exception('Failed to load manga: ${e.toString()}');
    }
  }

  Manga _parseMangaElement(Element element) {
    final titleElement = element.querySelector('.post-title h3 a');
    final coverElement = element.querySelector('.item-thumb a img');
    final ratingElement = element.querySelector('.post-total-rating .score');
    final chapterElement = element
        .querySelector('.list-chapter .chapter-item:first-child .chapter a');
    final updateElement = element.querySelector(
        '.list-chapter .chapter-item:first-child .post-on .c-new-tag a');
    print(titleElement?.attributes['href']);
    return Manga(
      id: titleElement?.attributes['href']
              ?.split('/')
              .where((s) => s.isNotEmpty)
              .last ??
          '',
      title: titleElement?.text.trim() ?? 'No title',
      url: titleElement?.attributes['href'] ?? '',
      coverUrl: coverElement?.attributes['src'] ?? '',
      rating: double.tryParse(ratingElement?.text.trim() ?? '0') ?? 0.0,
      latestChapter: chapterElement?.text.trim(),
      chapterUrl: chapterElement?.attributes['href'],
      updated: updateElement?.attributes['title'],
    );
  }

  Future<Manga> fetchMangaDetails(String url) async {
    try {
      // Ensure URL is absolute
      if (!url.startsWith('http')) {
        url = 'https://lekmanga.net$url';
      }

      final response = await _dio.get(url);
      final document = parser.parse(response.data);

      // Extract all manga details
      final title =
          document.querySelector('.post-title h1')?.text.trim() ?? 'No title';
      final coverUrl =
          document.querySelector('.summary_image img')?.attributes['src'] ?? '';

      // Description
      final descriptionElements =
          document.querySelectorAll('.summary__content p');
      final description =
          descriptionElements.map((e) => e.text.trim()).join('\n\n');

      // Rating
      final ratingText =
          document.querySelector('.post-total-rating .score')?.text.trim();
      final rating = double.tryParse(ratingText ?? '0') ?? 0.0;

      // Alternative names
      //  final alternativeNamesElement = document.querySelector('.post-content_item:contains("Alternative") .summary-content');
      //final alternativeNames = alternativeNamesElement?.text.trim().split(', ');

      // Author
      final author = document.querySelector('.author-content a')?.text.trim();

      // Artist
      final artist = document.querySelector('.artist-content a')?.text.trim();

      // Genres
      final genreElements = document.querySelectorAll('.genres-content a');
      final genres = genreElements.map((e) => e.text.trim()).toList();

      // Status
      final status =
          document.querySelector('.summary-content .status')?.text.trim();

      // Chapters
      final chapters = await _fetchChapters(document);

      return Manga(
        id: url.split('/').where((s) => s.isNotEmpty).last,
        title: title,
        url: url,
        coverUrl: coverUrl,
        rating: rating,
        description: description.isNotEmpty ? description : null,
        // alternativeNames: alternativeNames,
        author: author,
        artist: artist,
        genres: genres.isNotEmpty ? genres : null,
        status: status,
        chapters: chapters,
      );
    } catch (e) {
      throw Exception('Failed to load manga details: ${e.toString()}');
    }
  }

  Future<List<Chapter>> _fetchChapters(Document document) async {
    final chapterElements = document.querySelectorAll('.wp-manga-chapter');
    return chapterElements.map((element) {
      final chapterLink = element.querySelector('a');
      final dateElement = element.querySelector('.chapter-release-date');

      return Chapter(
        id: chapterLink?.attributes['href']
                ?.split('/')
                .where((s) => s.isNotEmpty)
                .last ??
            '',
        title: chapterLink?.text.trim() ?? 'No title',
        url: chapterLink?.attributes['href'] ?? '',
        date: dateElement?.text.trim(),
        pages: [], // Will be loaded separately
      );
    }).toList();
  }

  Future<Chapter> fetchChapterPages(String url) async {
    try {
      final response = await _dio.get(url);
      final document = parser.parse(response.data);

      final pageElements = document.querySelectorAll('.reading-content img');
      final pages = pageElements
          .map((e) => e.attributes['data-src'] ?? e.attributes['src'] ?? '')
          .where((src) => src.isNotEmpty)
          .toList();

      return Chapter(
        id: url.split('/').where((s) => s.isNotEmpty).last,
        title:
            document.querySelector('.chapter-title')?.text.trim() ?? 'Chapter',
        url: url,
        pages: pages,
      );
    } catch (e) {
      throw Exception('Failed to load chapter pages: ${e.toString()}');
    }
  }

  Future<List<Manga>> searchManga(String query) async {
    try {
      final response = await _dio.get('/', queryParameters: {'s': query});
      final document = parser.parse(response.data);

      final mangaElements = document
          .querySelectorAll('.page-listing-item .page-item-detail.manga');
      return mangaElements
          .map((element) => _parseMangaElement(element))
          .toList();
    } catch (e) {
      throw Exception('Failed to search manga: ${e.toString()}');
    }
  }
}
