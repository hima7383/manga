import 'package:hive/hive.dart';
part 'chapter.g.dart'; // This line is crucial for code generation

@HiveType(typeId: 1)
class Chapter {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String url;
  @HiveField(3)
  final String? date;
  @HiveField(4)
  final List<String> pages;
  @HiveField(5)
  final bool isRead;

  Chapter({
    required this.id,
    required this.title,
    required this.url,
    this.date,
    required this.pages,
    this.isRead = false,
  });
  
  Chapter copyWith({
    String? id,
    String? title,
    String? url,
    String? date,
    List<String>? pages,
    bool? isRead,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      date: date ?? this.date,
      pages: pages ?? this.pages,
      isRead: isRead ?? this.isRead,
    );
  }
}