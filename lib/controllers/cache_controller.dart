import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/news_article.dart';

class CacheController extends GetxController {
  late Box<NewsArticle> _cacheBox;
  late Box _metadataBox;
  var cachedArticles = <NewsArticle>[].obs;
  var lastCacheTime = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _initCache();
  }

  Future<void> _initCache() async {
    _cacheBox = await Hive.openBox<NewsArticle>('news_cache');
    _metadataBox = await Hive.openBox('cache_metadata');
    loadCachedArticles();
    _loadLastCacheTime();
  }

  void loadCachedArticles() {
    cachedArticles.value = _cacheBox.values.toList();
  }

  void _loadLastCacheTime() {
    final timeStr = _metadataBox.get('last_cache_time');
    if (timeStr is String) {
      lastCacheTime.value = DateTime.tryParse(timeStr);
    }
  }

  Future<void> cacheArticles(List<NewsArticle> articles) async {
    try {
      await _cacheBox.clear();

      for (var article in articles) {
        await _cacheBox.add(article);
      }

      await _metadataBox.put(
        'last_cache_time',
        DateTime.now().toIso8601String(),
      );

      loadCachedArticles();
      lastCacheTime.value = DateTime.now();

      print('Cached ${articles.length} articles');
    } catch (e) {
      print('Error caching articles: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      await _cacheBox.clear();
      cachedArticles.clear();
      lastCacheTime.value = null;
      print('Cache cleared');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  bool isCacheExpired({int maxAgeMinutes = 30}) {
    if (lastCacheTime.value == null) return true;

    final difference = DateTime.now().difference(lastCacheTime.value!);
    return difference.inMinutes > maxAgeMinutes;
  }

  bool get hasCachedData => cachedArticles.isNotEmpty;
}
