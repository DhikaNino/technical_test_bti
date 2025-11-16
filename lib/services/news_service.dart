import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class NewsService {
  static const String _apiKey = '54957220e7f147e183bba81f56bb712c';
  static const String _baseUrl = 'https://newsapi.org/v2/top-headlines?';

  Future<List<NewsArticle>> getTopHeadlines({
    String country = 'us',
    String? category,
    int pageSize = 10,
    int page = 1,
  }) async {
    try {
      final queryParams = {
        'apiKey': _apiKey,
        'country': country,
        'pageSize': pageSize.toString(),
        'page': page.toString(),
        if (category != null) 'category': category,
      };

      final uri = Uri.parse(
        '$_baseUrl/top-headlines',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles =
            (data['articles'] as List)
                .map((article) => NewsArticle.fromJson(article))
                .toList();
        return articles;
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NewsArticle>> searchNews({
    required String query,
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = {
        'apiKey': _apiKey,
        'q': query,
        'pageSize': pageSize.toString(),
        'page': page.toString(),
        'sortBy': 'publishedAt',
      };

      final uri = Uri.parse(
        '$_baseUrl/everything',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles =
            (data['articles'] as List)
                .map((article) => NewsArticle.fromJson(article))
                .toList();
        return articles;
      } else {
        throw Exception('Gagal load data berita: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
