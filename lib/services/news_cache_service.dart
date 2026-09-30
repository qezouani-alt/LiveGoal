import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'news_service.dart';

class NewsCacheService {
  static const String _cacheKey = 'cached_football_news';
  static const String _cacheTimestampKey = 'news_cache_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 1); // Cache for 1 hour

  /// Get cached news if available and not expired
  static Future<List<NewsArticle>?> getCachedNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (cachedData != null && timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();

        // Check if cache is still valid (not expired)
        if (now.difference(cacheTime) < _cacheExpiry) {
          final List<dynamic> articlesJson = json.decode(cachedData);
          return articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
        }
      }
    } catch (e) {
      // If there's an error reading cache, return null
    }
    return null;
  }

  /// Cache news articles
  static Future<void> cacheNews(List<NewsArticle> news) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final articlesJson = news.map((article) => article.toJson()).toList();
      final jsonString = json.encode(articlesJson);
      
      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // If caching fails, continue without caching
    }
  }

  /// Clear cached news
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
    } catch (e) {
      // If clearing fails, continue
    }
  }

  /// Check if cache exists and is valid
  static Future<bool> hasValidCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        return now.difference(cacheTime) < _cacheExpiry;
      }
    } catch (e) {
      // If there's an error, assume no valid cache
    }
    return false;
  }

  /// Get news with cache-first strategy
  static Future<List<NewsArticle>> getNewsWithCache() async {
    // First, try to get cached news
    final cachedNews = await getCachedNews();
    if (cachedNews != null && cachedNews.isNotEmpty) {
      return cachedNews;
    }

    // If no valid cache, fetch fresh news
    try {
      final freshNews = await NewsService.getFootballNewsWithPagination(totalArticles: 300);
      // Cache the fresh news for future use
      await cacheNews(freshNews);
      return freshNews;
    } catch (e) {
      // If fetching fails, return empty list
      return [];
    }
  }
}
