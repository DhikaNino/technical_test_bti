import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/news_article.dart';

class FavoriteController extends GetxController {
  late Box<NewsArticle> _favoritesBox;
  var favorites = <NewsArticle>[].obs;

  @override
  void onInit() {
    super.onInit();
    _favoritesBox = Hive.box<NewsArticle>('favorites');
    loadFavorites();
  }

  void loadFavorites() {
    favorites.value = _favoritesBox.values.toList();
  }

  bool isFavorite(String url) {
    return _favoritesBox.values.any((article) => article.url == url);
  }

  bool toggleFavorite(NewsArticle article) {
    try {
      bool wasRemoved = false;
      if (isFavorite(article.url)) {
        final key = _favoritesBox.keys.firstWhere(
          (k) => _favoritesBox.get(k)?.url == article.url,
        );
        _favoritesBox.delete(key);
        wasRemoved = true;
      } else {
        final newArticle = article.copyWith();
        _favoritesBox.add(newArticle);
        wasRemoved = false;
      }
      loadFavorites();
      update();
      return wasRemoved;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  void removeFavorite(String url) {
    try {
      final key = _favoritesBox.keys.firstWhere(
        (k) => _favoritesBox.get(k)?.url == url,
      );
      _favoritesBox.delete(key);
      loadFavorites();
      update();
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }
}
