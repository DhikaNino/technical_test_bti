import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/news_service.dart';
import '../models/news_article.dart';
import 'news_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _newsService = NewsService();
  final _authService = AuthService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  List<NewsArticle> _articles = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _errorMessage;
  String _selectedKategori = 'general';
  bool _isSearching = false;
  int _currentPage = 1;
  bool _loadData = true;
  Timer? _debounce;

  final List<Map<String, String>> _kategori = [
    {'value': 'general', 'label': 'Umum'},
    {'value': 'business', 'label': 'Bisnis'},
    {'value': 'entertainment', 'label': 'Hiburan'},
    {'value': 'health', 'label': 'Kesehatan'},
    {'value': 'science', 'label': 'Ilmu Pengetahuan'},
    {'value': 'sports', 'label': 'Olahraga'},
    {'value': 'technology', 'label': 'Teknologi'},
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 500 &&
        !_loadingMore &&
        _loadData &&
        !_loading) {
      _loadMoreNews();
    }
  }

  Future<void> _loadNews() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _currentPage = 1;
      _loadData = true;
    });

    try {
      List<NewsArticle> articles;
      if (_isSearching && _searchController.text.isNotEmpty) {
        articles = await _newsService.searchNews(
          query: _searchController.text,
          page: 1,
        );
      } else {
        articles = await _newsService.getTopHeadlines(
          category: _selectedKategori,
          page: 1,
        );
      }

      if (mounted) {
        setState(() {
          _articles = articles;
          _loading = false;
          _loadData = articles.length >= 10;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMoreNews() async {
    if (_loadingMore || !_loadData) return;

    setState(() {
      _loadingMore = true;
      _currentPage++;
    });

    try {
      List<NewsArticle> newArticles;
      if (_isSearching && _searchController.text.isNotEmpty) {
        newArticles = await _newsService.searchNews(
          query: _searchController.text,
          page: _currentPage,
        );
      } else {
        newArticles = await _newsService.getTopHeadlines(
          category: _selectedKategori,
          page: _currentPage,
        );
      }

      if (mounted) {
        setState(() {
          _articles.addAll(newArticles);
          _loadingMore = false;
          _loadData = newArticles.length >= 10;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingMore = false;
          _currentPage--;
        });
      }
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
      _loadNews();
    }
  }

  void _showFilterDialog() {
    String tempCategory = _selectedKategori;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.filter_list,
                                color: Colors.deepPurple,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Filter Berita',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.category,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Category',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  _kategori.map((category) {
                                    final isSelected =
                                        category['value'] == tempCategory;
                                    return GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          tempCategory = category['value']!;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? Colors.deepPurple
                                                  : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? Colors.deepPurple
                                                    : Colors.grey[300]!,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Text(
                                          category['label']!,
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      side: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _selectedKategori = tempCategory;
                                        _isSearching = false;
                                        _searchController.clear();
                                      });
                                      _loadNews();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Terapkan',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
          ),
    );
  }

  void _openArticleDetail(NewsArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(article: article),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Beritaku',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  PopupMenuButton<String>(
                    icon: CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                      child:
                          user?.photoURL == null
                              ? const Icon(Icons.person, size: 20)
                              : null,
                    ),
                    itemBuilder:
                        (context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            enabled: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.displayName ?? 'User',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user?.email ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem<String>(
                            value: 'logout',
                            child: const Row(
                              children: [
                                Icon(Icons.logout, size: 20),
                                SizedBox(width: 8),
                                Text('Logout'),
                              ],
                            ),
                          ),
                        ],
                    onSelected: (value) async {
                      if (value == 'logout') {
                        await _authService.signOut();
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari berita...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _isSearching = false;
                                    });
                                    _loadNews();
                                  },
                                )
                                : null,
                        filled: true,
                        fillColor: Colors.grey[100],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _onSearchSubmitted,
                      onChanged: (value) {
                        setState(() {});
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 800),
                          () {
                            if (value.isNotEmpty) {
                              setState(() {
                                _isSearching = true;
                              });
                              _loadNews();
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _showFilterDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  _loading
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text('Memuat berita...'),
                          ],
                        ),
                      )
                      : _errorMessage != null
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load news',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _loadNews,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: _loadNews,
                        child:
                            _articles.isEmpty
                                ? const Center(
                                  child: Text(
                                    'Tidak ada berita yang ditemukan',
                                  ),
                                )
                                : ListView.builder(
                                  controller: _scrollController,
                                  itemCount: _articles.length + 1,
                                  padding: const EdgeInsets.all(8),
                                  itemBuilder: (context, index) {
                                    if (index == _articles.length) {
                                      if (_loadingMore) {
                                        return Container(
                                          padding: const EdgeInsets.all(16),
                                          alignment: Alignment.center,
                                          child: Column(
                                            children: [
                                              Text(
                                                'Memuat berita lainnya...',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else if (!_loadData &&
                                          _articles.isNotEmpty) {
                                        return Container(
                                          padding: const EdgeInsets.all(24),
                                          alignment: Alignment.center,
                                          child: Column(
                                            children: [
                                              Text(
                                                'Tidak ada berita lainnya, hanya ada ${_articles.length} berita.',
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    }

                                    final article = _articles[index];
                                    return Card(
                                      color: Colors.white,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap:
                                            () => _openArticleDetail(article),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (article.urlToImage != null)
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                      top: Radius.circular(12),
                                                    ),
                                                child: Image.network(
                                                  article.urlToImage!,
                                                  height: 200,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Container(
                                                      height: 200,
                                                      color: Colors.grey[300],
                                                      child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 64,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (article.source != null)
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors
                                                                .deepPurple
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  4,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            article
                                                                .source!
                                                                .name,
                                                            style: const TextStyle(
                                                              color:
                                                                  Colors
                                                                      .deepPurple,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          _formatDate(
                                                            article.publishedAt,
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    article.title,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      height: 1.3,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  if (article.description !=
                                                      null) ...[
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      article.description!,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[700],
                                                        height: 1.4,
                                                      ),
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.open_in_new,
                                                        size: 16,
                                                        color:
                                                            Colors.deepPurple,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Baca Selengkapnya',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.deepPurple,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
