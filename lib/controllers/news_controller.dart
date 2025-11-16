import 'dart:async';
import 'package:get/get.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';

class NewsController extends GetxController {
  final NewsService _newsService = NewsService();

  var articles = <NewsArticle>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var errorMessage = ''.obs;
  var selectedCategory = 'general'.obs;
  var isSearching = false.obs;
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  var searchQuery = ''.obs;

  Timer? _debounce;

  final List<Map<String, String>> categories = [
    {'value': 'general', 'label': 'Umum'},
    {'value': 'business', 'label': 'Bisnis'},
    {'value': 'entertainment', 'label': 'Hiburan'},
    {'value': 'health', 'label': 'Kesehatan'},
    {'value': 'science', 'label': 'Ilmu Pengetahuan'},
    {'value': 'sports', 'label': 'Olahraga'},
    {'value': 'technology', 'label': 'Teknologi'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadNews();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadNews() async {
    isLoading.value = true;
    errorMessage.value = '';
    currentPage.value = 1;
    hasMoreData.value = true;

    try {
      List<NewsArticle> newArticles;
      if (isSearching.value && searchQuery.value.isNotEmpty) {
        newArticles = await _newsService.searchNews(
          query: searchQuery.value,
          page: 1,
        );
      } else {
        newArticles = await _newsService.getTopHeadlines(
          category: selectedCategory.value,
          page: 1,
        );
      }

      articles.value = newArticles;
      hasMoreData.value = newArticles.length >= 10;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreNews() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    isLoadingMore.value = true;
    currentPage.value++;

    try {
      List<NewsArticle> newArticles;
      if (isSearching.value && searchQuery.value.isNotEmpty) {
        newArticles = await _newsService.searchNews(
          query: searchQuery.value,
          page: currentPage.value,
        );
      } else {
        newArticles = await _newsService.getTopHeadlines(
          category: selectedCategory.value,
          page: currentPage.value,
        );
      }

      articles.addAll(newArticles);
      hasMoreData.value = newArticles.length >= 10;
    } catch (e) {
      currentPage.value--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (value.isNotEmpty) {
        isSearching.value = true;
        loadNews();
      }
    });
  }

  void clearSearch() {
    searchQuery.value = '';
    isSearching.value = false;
    loadNews();
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    isSearching.value = false;
    searchQuery.value = '';
    loadNews();
  }
}
