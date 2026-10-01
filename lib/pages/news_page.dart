import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../services/news_service.dart';
import 'article_details_page.dart';

class NewsPage extends StatefulWidget {
  final List<NewsArticle> globalNews;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  const NewsPage({
    super.key,
    required this.globalNews,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
  });

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<NewsArticle> _filteredNews = [];
  String _searchQuery = '';
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateFilteredNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NewsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.globalNews != widget.globalNews) {
      _updateFilteredNews();
    }
  }

  void _updateFilteredNews() {
    setState(() {
      _filteredNews = widget.globalNews;
    });
    _filterNews();
  }

  void _filterNews() {
    setState(() {
      _filteredNews = widget.globalNews.where((article) {
        final matchesSearch = _searchQuery.isEmpty ||
            article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            article.description.toLowerCase().contains(_searchQuery.toLowerCase());
        
        return matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _filterNews();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style to remove black backgrounds
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Elegant Animated Background
          _buildElegantBackground(),
          // Main Content
          SafeArea(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.99,
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),
                    // Content
                    Expanded(child: _buildContent()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        width: MediaQuery.of(context).size.width * 0.99,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.8),
              Colors.white.withValues(alpha: 0.7),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFFF4D00).withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
          controller: _searchController,
          onChanged: (value) => _onSearchChanged(),
          decoration: InputDecoration(
            hintText: 'Search football news...',
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: const Color(0xFFFF4D00),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged();
                    },
                  )
                : null,
          border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }



  Widget _buildNewsList() {
    if (_filteredNews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No news found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or category',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20), // Add bottom padding to prevent content hiding under tabview
        itemCount: _filteredNews.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailsPage(
                    article: _filteredNews[index],
                  ),
                ),
              );
            },
            child: _buildNewsCard(_filteredNews[index]),
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // News Image
          if (article.urlToImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                article.urlToImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // News Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  softWrap: true,
                ),
                
                const SizedBox(height: 8),
                
                // Description
                Text(
                  article.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // Meta Information
                Row(
                  children: [
                    // Source
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.source.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Time Ago
                    Text(
                      article.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                
                // Author (if available)
                if (article.author != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'By ${article.author}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading football news...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fetching up to 300 articles',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading News',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.error ?? 'Unknown error occurred',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        width: MediaQuery.of(context).size.width * 0.99,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article,
              color: const Color(0xFF002366),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              "Football News",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002366),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                _isSearchVisible ? Icons.close : Icons.search,
                color: const Color(0xFF002366),
              ),
              onPressed: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                  if (!_isSearchVisible) {
                    _searchController.clear();
                    _onSearchChanged();
                  }
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.blue.shade600),
              onPressed: widget.onRefresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar (conditional)
          if (_isSearchVisible) _buildSearchBar(),
          
          // News List
          Expanded(
            child: widget.isLoading
                ? _buildLoadingWidget()
                : widget.error != null
                    ? _buildErrorWidget()
                    : _buildNewsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantBackground() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 8),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: CustomPaint(
            painter: ColorfulDotsPainter(value),
            size: Size.infinite,
          ),
        );
      },
      onEnd: () {
        // Restart animation
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
}

class ColorfulDotsPainter extends CustomPainter {
  final double animationValue;

  ColorfulDotsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw colorful floating dots
    _drawColorfulDots(canvas, size, paint);
  }

  void _drawColorfulDots(Canvas canvas, Size size, Paint paint) {
    // Create colorful floating dots
    for (int i = 0; i < 20; i++) {
      final x = (i * 150.0 + animationValue * 100) % size.width;
      final y = (i * 100.0 + animationValue * 80) % size.height;
      final dotSize = 1.5 + (i % 3) * 1.0;
      
      // Different movement patterns for natural floating
      final movementX = math.sin(animationValue * 1.2 * 3.14159 + i) * 40;
      final movementY = math.cos(animationValue * 1.8 * 3.14159 + i) * 30;
      
      final dotX = (x + movementX) % size.width;
      final dotY = (y + movementY) % size.height;
      
      // Colorful dots with different colors
      final colors = [
        const Color(0xFFFF6B6B), // Red
        const Color(0xFF4ECDC4), // Teal
        const Color(0xFF45B7D1), // Blue
        const Color(0xFF96CEB4), // Green
        const Color(0xFFFECA57), // Yellow
        const Color(0xFFFF9FF3), // Pink
        const Color(0xFF54A0FF), // Light Blue
        const Color(0xFF5F27CD), // Purple
        const Color(0xFF00D2D3), // Cyan
        const Color(0xFFFF9F43), // Orange
      ];
      
      paint.color = colors[i % colors.length].withValues(alpha: 0.6);
      
      canvas.drawCircle(
        Offset(dotX, dotY),
        dotSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

