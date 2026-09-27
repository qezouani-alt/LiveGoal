import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  // You'll need to get your API key from https://newsapi.org/account
  static const String _apiKey = '11e05abb40cc40eda548f625f721edee';
  static const String _baseUrl = 'https://newsapi.org/v2';

  /// Get football news from NewsAPI
  static Future<List<NewsArticle>> getFootballNews({
    String? country = 'us',
    String? category = 'sports',
    String? query = 'soccer OR "Premier League" OR "La Liga" OR "Bundesliga" OR "Serie A" OR "Champions League" OR "World Cup" OR "UEFA" OR "FIFA" OR "transfer window" OR "soccer player" OR "football club" OR "striker" OR "midfielder" OR "defender" OR "goalkeeper"',
    int pageSize = 100, // Maximum allowed by NewsAPI
  }) async {
    try {
      // Build the API URL with specific football terms
      String url = '$_baseUrl/everything?';
      url += 'q=$query';
      url += '&language=en';
      url += '&sortBy=publishedAt';
      url += '&pageSize=$pageSize';
      url += '&apiKey=$_apiKey';
      url += '&excludeDomains=espn.com,nfl.com,ncaa.com'; // Exclude American sports sites

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok' && data['articles'] != null) {
          final articles = (data['articles'] as List)
              .map((article) => NewsArticle.fromJson(article))
              .toList();
          
          // Filter to ensure only football-related news
          return _filterFootballNews(articles);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your NewsAPI key.');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please try again later.');
      }
      
      throw Exception('Failed to load news');
    } catch (e) {
      // For demo purposes, return sample data
      final demoNews = _getDemoNews();
      return _filterFootballNews(demoNews);
    }
  }

  /// Get top football headlines
  static Future<List<NewsArticle>> getTopHeadlines({
    String? country = 'us',
    String? category = 'sports',
    int pageSize = 100, // Maximum allowed by NewsAPI
  }) async {
    try {
      String url = '$_baseUrl/top-headlines?';
      url += 'country=$country';
      url += '&category=$category';
      url += '&pageSize=$pageSize';
      url += '&apiKey=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok' && data['articles'] != null) {
          final articles = (data['articles'] as List)
              .map((article) => NewsArticle.fromJson(article))
              .toList();
          
          // Filter to ensure only football-related news
          return _filterFootballNews(articles);
        }
        
      }
      
      throw Exception('Failed to load headlines');
    } catch (e) {
      // For demo purposes, return sample data
      final demoNews = _getDemoNews();
      return _filterFootballNews(demoNews);
    }
  }

  /// Get football news with pagination to fetch more than 100 articles
  static Future<List<NewsArticle>> getFootballNewsWithPagination({
    int totalArticles = 300, // Fetch up to 300 articles
  }) async {
    try {
            List<NewsArticle> allArticles = [];
      int articlesPerPage = 100; // Maximum per request
      
      while (allArticles.length < totalArticles) {
        try {
          final articles = await getFootballNews(
            pageSize: articlesPerPage,
          );
          
          if (articles.isEmpty) break; // No more articles available
          
          allArticles.addAll(articles);
          
          // Add delay to respect API rate limits
          if (allArticles.length < totalArticles) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        } catch (e) {
          // Log error for debugging
          break;
        }
      }
      
      // Remove duplicates based on URL
      final uniqueArticles = <String, NewsArticle>{};
      for (final article in allArticles) {
        uniqueArticles[article.url] = article;
      }
      
      return uniqueArticles.values.toList();
    } catch (e) {
      // Log error for debugging
      // Fallback to single request
      return await getFootballNews();
    }
  }

  /// Demo mode - returns sample news data
  static List<NewsArticle> _getDemoNews() {
    return [
      NewsArticle(
        title: 'Manchester United Signs New Star Striker',
        description: 'The Red Devils have completed the signing of a world-class striker to strengthen their attack for the upcoming season.',
        content: 'Manchester United has announced the signing of a new striker in a deal worth €80 million. The player is expected to make his debut in the next Premier League match.',
        url: 'https://example.com/news1',
        urlToImage: 'https://via.placeholder.com/400x250/1a1a1a/ffffff?text=MU+News',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        source: NewsSource(id: 'man-utd', name: 'Manchester United Official'),
        author: 'John Smith',
      ),
      NewsArticle(
        title: 'Champions League Final Set for Epic Showdown',
        description: 'Two European giants will face off in what promises to be one of the most exciting Champions League finals in recent history.',
        content: 'The stage is set for an epic Champions League final between two of Europe\'s most successful clubs. Both teams have been in excellent form throughout the tournament.',
        url: 'https://example.com/news2',
        urlToImage: 'https://via.placeholder.com/400x250/0066cc/ffffff?text=UCL+Final',
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
        source: NewsSource(id: 'uefa', name: 'UEFA Official'),
        author: 'Maria Garcia',
      ),
      NewsArticle(
        title: 'World Cup 2026 Host Cities Announced',
        description: 'FIFA has revealed the host cities for the 2026 World Cup, which will be the first tournament to feature 48 teams.',
        content: 'The 2026 World Cup will be hosted across multiple cities in North America, marking a historic moment for football in the region.',
        url: 'https://example.com/news3',
        urlToImage: 'https://via.placeholder.com/400x250/00aa00/ffffff?text=World+Cup+2026',
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        source: NewsSource(id: 'fifa', name: 'FIFA Official'),
        author: 'David Wilson',
      ),
      NewsArticle(
        title: 'Real Madrid Dominates La Liga Season',
        description: 'Los Blancos continue their impressive form with another convincing victory in the Spanish top flight.',
        content: 'Real Madrid has extended their lead at the top of La Liga with a commanding performance that showcases their title credentials.',
        url: 'https://example.com/news4',
        urlToImage: 'https://via.placeholder.com/400x250/ffffff/000000?text=Real+Madrid',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        source: NewsSource(id: 'realmadrid', name: 'Real Madrid CF'),
        author: 'Carlos Rodriguez',
      ),
      NewsArticle(
        title: 'Bayern Munich Eyes Bundesliga Record',
        description: 'The German giants are on course to break several Bundesliga records this season.',
        content: 'Bayern Munich\'s exceptional form has put them in position to challenge multiple Bundesliga records this campaign.',
        url: 'https://example.com/news5',
        urlToImage: 'https://via.placeholder.com/400x250/ff0000/ffffff?text=Bayern+Munich',
        publishedAt: DateTime.now().subtract(const Duration(hours: 10)),
        source: NewsSource(id: 'bayern', name: 'Bayern Munich'),
        author: 'Hans Mueller',
      ),
      NewsArticle(
        title: 'Juventus Announces New Manager',
        description: 'The Italian club has appointed a new head coach to lead them into the next era.',
        content: 'Juventus has made a significant managerial change as they look to return to the top of Italian football.',
        url: 'https://example.com/news6',
        urlToImage: 'https://via.placeholder.com/400x250/000000/ffffff?text=Juventus',
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
        source: NewsSource(id: 'juventus', name: 'Juventus FC'),
        author: 'Marco Rossi',
      ),
      NewsArticle(
        title: 'Premier League Transfer Window Heats Up',
        description: 'English clubs are making major moves in the transfer market as the deadline approaches.',
        content: 'The Premier League transfer window is reaching its climax with several high-profile deals being finalized.',
        url: 'https://example.com/news7',
        urlToImage: 'https://via.placeholder.com/400x250/3700ff/ffffff?text=Premier+League',
        publishedAt: DateTime.now().subtract(const Duration(hours: 14)),
        source: NewsSource(id: 'premierleague', name: 'Premier League'),
        author: 'James Thompson',
      ),
      NewsArticle(
        title: 'PSG Star Extends Contract',
        description: 'The French champions have secured the long-term future of their star player.',
        content: 'Paris Saint-Germain has successfully negotiated a contract extension with one of their key players.',
        url: 'https://example.com/news8',
        urlToImage: 'https://via.placeholder.com/400x250/0000ff/ffffff?text=PSG',
        publishedAt: DateTime.now().subtract(const Duration(hours: 16)),
        source: NewsSource(id: 'psg', name: 'Paris Saint-Germain'),
        author: 'Pierre Dubois',
      ),
      NewsArticle(
        title: 'Transfer Window: Record Breaking Deals',
        description: 'This summer\'s transfer window has seen unprecedented spending as clubs break transfer records left and right.',
        content: 'The transfer market has been incredibly active this summer, with several clubs breaking their own transfer records in pursuit of top talent.',
        url: 'https://example.com/news4',
        urlToImage: 'https://via.placeholder.com/400x250/ff6600/ffffff?text=Transfer+News',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        source: NewsSource(id: 'transfer-news', name: 'Transfer Central'),
        author: 'Sarah Johnson',
      ),
      NewsArticle(
        title: 'Young Talent Emerges in Premier League',
        description: 'A new generation of football stars is emerging in the Premier League, showcasing the league\'s commitment to developing young talent.',
        content: 'Several young players have been making waves in the Premier League this season, proving that the future of English football is bright.',
        url: 'https://example.com/news5',
        urlToImage: 'https://via.placeholder.com/400x250/cc0000/ffffff?text=Young+Talent',
        publishedAt: DateTime.now().subtract(const Duration(hours: 10)),
        source: NewsSource(id: 'premier-league', name: 'Premier League'),
        author: 'Michael Brown',
      ),
    ];
  }

  /// Filter news to show only football-related articles
  static List<NewsArticle> _filterFootballNews(List<NewsArticle> news) {
    final footballKeywords = [
      'soccer', 'premier league', 'la liga', 'bundesliga',
      'serie a', 'champions league', 'world cup', 'euro', 'transfer',
      'manchester united', 'manchester city', 'liverpool', 'arsenal',
      'chelsea', 'barcelona', 'real madrid', 'bayern munich', 'psg',
      'goal', 'match', 'player', 'team', 'league', 'cup', 'trophy',
      'uefa', 'fifa', 'striker', 'midfielder', 'defender', 'goalkeeper',
      'penalty', 'corner', 'free kick', 'offside', 'injury', 'substitution',
      'coach', 'manager', 'training', 'stadium', 'fans', 'supporters',
      'premier league', 'bundesliga', 'serie a', 'ligue 1', 'eredivisie',
      'primeira liga', 'scottish premiership', 'belgian pro league'
    ];
    
    return news.where((article) {
      final title = article.title.toLowerCase();
      final description = article.description.toLowerCase();
      final content = article.content.toLowerCase();
      
      // Check if any football keyword is present
      final hasFootballKeyword = footballKeywords.any((keyword) =>
          title.contains(keyword) ||
          description.contains(keyword) ||
          content.contains(keyword));
      
      // Additional check: exclude articles that are clearly not football
      final nonFootballTerms = [
        'basketball', 'tennis', 'golf', 'baseball', 'hockey', 'rugby',
        'cricket', 'volleyball', 'swimming', 'athletics', 'olympics',
        'american football', 'nfl', 'quarterback', 'touchdown', 'field goal',
        'super bowl', 'ncaa football', 'college football', 'gridiron',
        'football player', 'football team' // Too generic, might include American football
      ];
      
      final hasNonFootballTerm = nonFootballTerms.any((term) =>
          title.contains(term) ||
          description.contains(term) ||
          content.contains(term));
      
      // Special check: exclude American football articles
      final americanFootballTerms = [
        'nfl', 'quarterback', 'touchdown', 'field goal', 'super bowl',
        'ncaa football', 'college football', 'gridiron', 'end zone',
        'first down', 'huddle', 'snap', 'punt', 'kickoff'
      ];
      
      final hasAmericanFootballTerm = americanFootballTerms.any((term) =>
          title.contains(term) ||
          description.contains(term) ||
          content.contains(term));
      
      return hasFootballKeyword && !hasNonFootballTerm && !hasAmericanFootballTerm;
    }).toList();
  }
}

class NewsArticle {
  final String title;
  final String description;
  final String content;
  final String url;
  final String? urlToImage;
  final DateTime publishedAt;
  final NewsSource source;
  final String? author;

  NewsArticle({
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    required this.source,
    this.author,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      content: json['content'] ?? json['description'] ?? 'No Content',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt'])
          : DateTime.now(),
      source: NewsSource.fromJson(json['source'] ?? {}),
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt.toIso8601String(),
      'source': source.toJson(),
      'author': author,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class NewsSource {
  final String? id;
  final String name;

  NewsSource({
    this.id,
    required this.name,
  });

  factory NewsSource.fromJson(Map<String, dynamic> json) {
    return NewsSource(
      id: json['id'],
      name: json['name'] ?? 'Unknown Source',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
