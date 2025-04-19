// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MangaAdapter extends TypeAdapter<Manga> {
  @override
  final int typeId = 0;

  @override
  Manga read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Manga(
      id: fields[0] as String,
      title: fields[1] as String,
      url: fields[2] as String,
      coverUrl: fields[3] as String,
      rating: fields[4] as double,
      latestChapter: fields[5] as String?,
      chapterUrl: fields[6] as String?,
      updated: fields[7] as String?,
      description: fields[8] as String?,
      genres: (fields[9] as List?)?.cast<String>(),
      chapters: (fields[10] as List?)?.cast<Chapter>(),
      isBookmarked: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Manga obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.coverUrl)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.latestChapter)
      ..writeByte(6)
      ..write(obj.chapterUrl)
      ..writeByte(7)
      ..write(obj.updated)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.genres)
      ..writeByte(10)
      ..write(obj.chapters)
      ..writeByte(11)
      ..write(obj.isBookmarked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
