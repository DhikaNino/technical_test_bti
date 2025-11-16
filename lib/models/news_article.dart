import 'package:hive/hive.dart';

part 'news_article.g.dart';

@HiveType(typeId: 0)
class NewsArticle extends HiveObject {
  @HiveField(0)
  final String? author;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String url;

  @HiveField(4)
  final String? urlToImage;

  @HiveField(5)
  final DateTime publishedAt;

  @HiveField(6)
  final String? content;

  @HiveField(7)
  final Source? source;

  NewsArticle({
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
    this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      author: json['author'] as String?,
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String?,
      url: json['url'] as String? ?? '',
      urlToImage: json['urlToImage'] as String?,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      content: json['content'] as String?,
      source: json['source'] != null ? Source.fromJson(json['source']) : null,
    );
  }

  NewsArticle copyWith() {
    return NewsArticle(
      author: author,
      title: title,
      description: description,
      url: url,
      urlToImage: urlToImage,
      publishedAt: publishedAt,
      content: content,
      source:
          source != null ? Source(id: source!.id, name: source!.name) : null,
    );
  }
}

@HiveType(typeId: 1)
class Source {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String name;

  Source({this.id, required this.name});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Tidak diketahui',
    );
  }
}
