class AppConfig {
  // NewsAPI
  static const String newsApiKey = '54957220e7f147e183bba81f56bb712c';
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';
  static const String newsApiCountry = 'id';
  static const int newsApiPageSize = 10;

  // Firebase
  // Web Client ID
  static const String googleWebClientId =
      '706849939010-pdpf0bc6sfiirjku3m62ni0n0i2umgfn.apps.googleusercontent.com';

  // iOS Client ID
  static const String googleIosClientId =
      '706849939010-lsmtir8pppfsbcbrhmpeljo77ucr0er1.apps.googleusercontent.com';

  // App Information
  static const String appName = 'Beritaku';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Aplikasi berita terkini Indonesia';

  // Cache Configuration
  static const int cacheExpirationHours = 24;
  static const int maxCachedArticles = 100;

  // UI Configuration
  static const int searchDebounceMilliseconds = 500;
  static const int loadMoreThreshold = 500;

  // Categories
  static const List<String> newsCategories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  static const Map<String, String> categoryLabels = {
    'general': 'Umum',
    'business': 'Bisnis',
    'entertainment': 'Hiburan',
    'health': 'Kesehatan',
    'science': 'Sains',
    'sports': 'Olahraga',
    'technology': 'Teknologi',
  };
}
