import 'package:hive/hive.dart';
import 'chapter.dart';

part 'manga.g.dart';

@HiveType(typeId: 0)
class Manga {
  @HiveField(0) final String id;
  @HiveField(1) final String title;
  @HiveField(2) final String url;
  @HiveField(3) final String coverUrl;
  @HiveField(4) final double rating;
  @HiveField(5) final String? latestChapter;
  @HiveField(6) final String? chapterUrl;
  @HiveField(7) final String? updated;
  @HiveField(8) final String? description;
  @HiveField(9) final List<String>? genres;
  @HiveField(10) final List<Chapter>? chapters;
  @HiveField(11) final bool isBookmarked;
  @HiveField(12) final String? author;
  @HiveField(13) final String? artist;
  @HiveField(14) final String? status;
  @HiveField(15) final List<String>? alternativeNames;

  Manga({
    required this.id,
    required this.title,
    required this.url,
    required this.coverUrl,
    this.rating = 0.0,
    this.latestChapter,
    this.chapterUrl,
    this.updated,
    this.description,
    this.genres,
    this.chapters,
    this.isBookmarked = false,
    this.author,
    this.artist,
    this.status,
    this.alternativeNames,
  });

  // Add copyWith method including new fields
  Manga copyWith({
    String? id,
    String? title,
    String? url,
    String? coverUrl,
    double? rating,
    String? latestChapter,
    String? chapterUrl,
    String? updated,
    String? description,
    List<String>? genres,
    List<Chapter>? chapters,
    bool? isBookmarked,
    String? author,
    String? artist,
    String? status,
    List<String>? alternativeNames,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      coverUrl: coverUrl ?? this.coverUrl,
      rating: rating ?? this.rating,
      latestChapter: latestChapter ?? this.latestChapter,
      chapterUrl: chapterUrl ?? this.chapterUrl,
      updated: updated ?? this.updated,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      chapters: chapters ?? this.chapters,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      author: author ?? this.author,
      artist: artist ?? this.artist,
      status: status ?? this.status,
      alternativeNames: alternativeNames ?? this.alternativeNames,
    );
  }
}