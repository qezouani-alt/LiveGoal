import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/competition_matches_page.dart';
import 'services/api_football_service.dart';
import 'pages/news_page.dart';
import 'pages/settings_page.dart';
import 'pages/ai_search_page.dart';
import 'services/favorites_service.dart';
import 'models/favorite_competition.dart';
import 'services/news_cache_service.dart';
import 'services/news_service.dart';
import 'pages/splash_screen.dart';
import 'services/admob_service.dart';
import 'widgets/app_wallpaper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FootballApp());
}

class FootballApp extends StatelessWidget {
  const FootballApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiveGoal AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class FootballMatchesPage extends StatefulWidget {
  const FootballMatchesPage({super.key});

  @override
  State<FootballMatchesPage> createState() => _FootballMatchesPageState();
}

class _FootballMatchesPageState extends State<FootballMatchesPage>
    with WidgetsBindingObserver {
  int _selectedTabIndex = 0;

  // API-loaded competitions with today's matches
  List<CompetitionWithMatches> _todayCompetitions = [];
  List<CompetitionWithMatches> _filteredCompetitions = [];
  bool _isLoadingCompetitions = false;
  String? _competitionsError;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  // Global news state
  List<NewsArticle> _globalNews = [];
  bool _isLoadingNews = false;
  String? _newsError;

  // Favorites state
  List<FavoriteCompetition> _favoriteCompetitions = [];
  final Set<int> _updatingFavoriteIds = {};

  // Track app lifecycle to show app open ad only when truly resuming
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTodayCompetitions();
    _loadNewsOnStartup();
    _loadFavoriteCompetitions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Track when app goes to background (but not when interstitial is showing)
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Only set background flag if not showing an interstitial
      if (!AdmobService().isShowingInterstitial()) {
        _wasInBackground = true;
        debugPrint('📱 App went to background (not interstitial)');
      } else {
        debugPrint(
          '📱 Lifecycle changed but interstitial is showing, ignoring',
        );
      }
    }

    // Show app open ad ONLY when resuming from background (not on tab clicks or after interstitials)
    if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false; // Reset flag
      debugPrint('📱 App resumed from background, showing app open ad');
      // Add small delay to ensure interstitial is fully dismissed
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !AdmobService().isShowingInterstitial()) {
          AdmobService().showAppOpenAd();
        }
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _filterCompetitions();
    });
  }

  void _filterCompetitions() {
    final query = _searchController.text.trim().toLowerCase();
    final favoriteIds =
        _favoriteCompetitions.map((favorite) => favorite.id).toSet();
    _filteredCompetitions =
        _todayCompetitions.where((competition) {
          return !favoriteIds.contains(competition.id) &&
              competition.name.toLowerCase().contains(query);
        }).toList();
  }

  int get _availableCompetitionCount {
    final favoriteIds =
        _favoriteCompetitions.map((favorite) => favorite.id).toSet();
    return _todayCompetitions
        .where((competition) => !favoriteIds.contains(competition.id))
        .length;
  }

  Future<void> _loadNewsOnStartup() async {
    setState(() {
      _isLoadingNews = true;
      _newsError = null;
    });

    try {
      final news = await NewsCacheService.getNewsWithCache();
      setState(() {
        _globalNews = news;
        _isLoadingNews = false;
      });
    } catch (e) {
      setState(() {
        _newsError = e.toString();
        _isLoadingNews = false;
      });
    }
  }

  Future<void> _refreshNews() async {
    setState(() {
      _isLoadingNews = true;
      _newsError = null;
    });

    try {
      // Clear cache and fetch fresh news
      await NewsCacheService.clearCache();
      final news = await NewsService.getFootballNewsWithPagination(
        totalArticles: 300,
      );
      await NewsCacheService.cacheNews(news);

      setState(() {
        _globalNews = news;
        _isLoadingNews = false;
      });
    } catch (e) {
      setState(() {
        _newsError = e.toString();
        _isLoadingNews = false;
      });
    }
  }

  Future<void> _loadFavoriteCompetitions() async {
    try {
      final favorites = await FavoritesService.getFavoriteCompetitions();
      if (mounted) {
        setState(() {
          _favoriteCompetitions = favorites;
          _filterCompetitions();
        });
      }
    } catch (e) {
      // Handle error silently for favorites
    }
  }

  Future<void> _loadTodayCompetitions() async {
    setState(() {
      _isLoadingCompetitions = true;
      _competitionsError = null;
    });

    try {
      final today = DateTime.now();
      final dateString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final matches = await ApiFootballService.getMatchesByDate(dateString);

      // Group matches by competition
      Map<String, CompetitionWithMatches> competitionsMap = {};

      for (var match in matches) {
        final key = '${match.league.id}';
        if (!competitionsMap.containsKey(key)) {
          competitionsMap[key] = CompetitionWithMatches(
            id: match.league.id,
            name: match.league.name,
            country: match.league.country,
            logo: match.league.logo,
            flag: match.league.flag,
            matches: [],
          );
        }
        competitionsMap[key]!.matches.add(match);
      }

      setState(() {
        _todayCompetitions = competitionsMap.values.toList();
        // Sort alphabetically by name first, then by earliest match time
        _todayCompetitions.sort((a, b) {
          // First, sort alphabetically by name
          int nameComparison = a.name.compareTo(b.name);
          if (nameComparison != 0) {
            return nameComparison;
          }

          // If same name, sort by earliest match time
          String earliestTimeA = _getEarliestMatchTime(a.matches);
          String earliestTimeB = _getEarliestMatchTime(b.matches);

          // Compare times
          int timeComparison = earliestTimeA.compareTo(earliestTimeB);
          if (timeComparison != 0) {
            return timeComparison;
          }

          // If same time, sort by number of matches (most matches first)
          return b.matches.length.compareTo(a.matches.length);
        });
        _filterCompetitions();
        _isLoadingCompetitions = false;
      });
    } catch (e) {
      setState(() {
        _competitionsError = e.toString();
        _isLoadingCompetitions = false;
      });
    }
  }

  Future<void> _toggleFavorite(CompetitionWithMatches competition) async {
    if (_updatingFavoriteIds.contains(competition.id)) return;

    final wasFavorite = _favoriteCompetitions.any(
      (favorite) => favorite.id == competition.id,
    );
    final favorite = FavoriteCompetition(
      id: competition.id,
      name: competition.name,
      logo: competition.logo,
      country: competition.country,
    );

    setState(() => _updatingFavoriteIds.add(competition.id));
    final saved =
        wasFavorite
            ? await FavoritesService.removeFromFavorites(competition.id)
            : await FavoritesService.addToFavorites(favorite);
    if (!mounted) return;

    setState(() {
      _updatingFavoriteIds.remove(competition.id);
      if (saved) {
        if (wasFavorite) {
          _favoriteCompetitions.removeWhere(
            (item) => item.id == competition.id,
          );
        } else {
          _favoriteCompetitions.add(favorite.copyWith(isFavorite: true));
        }
        _filterCompetitions();
      }
    });

    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update favorites. Please try again.'),
        ),
      );
    }
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
          // Main Content with SafeArea
          SafeArea(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.99,
                child: _buildBody(),
              ),
            ),
          ),
          // Floating TabView
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigation(),
          ),
        ],
      ),
    );
  }

  String _getEarliestMatchTime(List<Match> matches) {
    if (matches.isEmpty) return '99:99';

    // Find the earliest time among all matches
    String earliestTime = '99:99';

    for (var match in matches) {
      String matchTime = match.time == 'TBD' ? '99:99' : match.time;

      // Prioritize live matches
      if (['LIVE', '1H', '2H', 'HT'].contains(match.status.toUpperCase())) {
        return '00:00'; // Live matches get highest priority
      }

      if (matchTime.compareTo(earliestTime) < 0) {
        earliestTime = matchTime;
      }
    }

    return earliestTime;
  }

  String _getNextMatchTime(List<Match> matches) {
    if (matches.isEmpty) return 'TBD';

    // Check for live matches first
    for (var match in matches) {
      if (['LIVE', '1H', '2H', 'HT'].contains(match.status.toUpperCase())) {
        return 'LIVE';
      }
    }

    // Find the earliest upcoming match
    String earliestTime = '99:99';
    for (var match in matches) {
      if (match.status.toUpperCase() == 'NS' ||
          match.status.toUpperCase() == 'TBD') {
        String matchTime = match.time == 'TBD' ? 'TBD' : match.time;
        if (matchTime != 'TBD' && matchTime.compareTo(earliestTime) < 0) {
          earliestTime = matchTime;
        }
      }
    }

    return earliestTime == '99:99' ? 'TBD' : earliestTime;
  }

  Widget _buildBody() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildCompetitionsOnly();
      case 1:
        return NewsPage(
          globalNews: _globalNews,
          isLoading: _isLoadingNews,
          error: _newsError,
          onRefresh: _refreshNews,
        );
      case 2:
        return const AISearchPage();
      case 3:
        return const SettingsPage();
      default:
        return _buildCompetitionsOnly();
    }
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
            color: const Color(0xFF002366).withValues(alpha: 0.3),
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
          decoration: InputDecoration(
            hintText: 'Search leagues...',
            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            prefixIcon: Icon(Icons.search, color: const Color(0xFF002366)),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey.shade600),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildCompetitionsOnly() {
    final query = _searchController.text.trim().toLowerCase();
    final visibleFavorites =
        _favoriteCompetitions
            .where((favorite) => favorite.name.toLowerCase().contains(query))
            .toList();

    return RefreshIndicator(
      onRefresh: _loadTodayCompetitions,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 0,
        ), // Remove extra space below list
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (visibleFavorites.isNotEmpty) ...[
                      // Favorites header
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          width: MediaQuery.of(context).size.width * 0.95,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                color: const Color(0xFF002366),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Favorites (${visibleFavorites.length})",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF002366),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    if (visibleFavorites.isNotEmpty) ...[
                      ...visibleFavorites.map((favorite) {
                        // Find the corresponding competition with matches
                        final competitionWithMatches = _todayCompetitions
                            .firstWhere(
                              (comp) => comp.id == favorite.id,
                              orElse:
                                  () => CompetitionWithMatches(
                                    id: favorite.id,
                                    name: favorite.name,
                                    country: favorite.country,
                                    logo: favorite.logo,
                                    flag: '',
                                    matches: [],
                                  ),
                            );
                        return _buildApiCompetitionItem(competitionWithMatches);
                      }),
                    ],

                    // All Matches Header with Search Icon
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        width: MediaQuery.of(context).size.width * 0.95,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title content (centered in its space)
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sports_soccer,
                                    color: const Color(0xFF002366),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "All Matches ($_availableCompetitionCount)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF002366),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Search Icon (right side)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSearchVisible = !_isSearchVisible;
                                  if (!_isSearchVisible) {
                                    _searchController.clear();
                                    _filterCompetitions();
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.0),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF002366,
                                    ).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF002366,
                                      ).withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isSearchVisible ? Icons.close : Icons.search,
                                  color: const Color(0xFF002366),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Search Bar (conditional)
                    if (_isSearchVisible) _buildSearchBar(),

                    if (_isLoadingCompetitions) ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'Loading today\'s matches...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue.shade400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This may take a few seconds',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (_competitionsError != null) ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading competitions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _competitionsError!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadTodayCompetitions,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF4D00),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (_todayCompetitions.isEmpty) ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.sports_soccer_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No matches today',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'There are no matches scheduled for today',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Competitions list as a sliver
            if (!_isLoadingCompetitions &&
                _competitionsError == null &&
                _filteredCompetitions.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildApiCompetitionItem(_filteredCompetitions[index]);
                }, childCount: _filteredCompetitions.length),
              ),

            // No results found message
            if (!_isLoadingCompetitions &&
                _competitionsError == null &&
                _filteredCompetitions.isEmpty &&
                visibleFavorites.isEmpty &&
                _searchController.text.isNotEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    width: MediaQuery.of(context).size.width * 0.95,
                    padding: const EdgeInsets.all(24),
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
                        color: const Color(0xFF002366).withValues(alpha: 0.3),
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
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No leagues found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Spacer to keep content scrollable above TabView
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildApiCompetitionItem(CompetitionWithMatches competition) {
    final isFavorite = _favoriteCompetitions.any(
      (favorite) => favorite.id == competition.id,
    );
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CompetitionMatchesPage(competition: competition),
          ),
        );
      },
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF002366).withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF002366).withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Competition Logo
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    competition.logo,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey[400],
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 16,
                              color: Colors.blue.shade400,
                            ),
                            Text(
                              competition.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade300,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Live status indicator (left of title)
                        if (competition.matches.any(
                          (match) =>
                              ['LIVE', '1H', '2H'].contains(match.status),
                        )) ...[
                          _buildAnimatedLiveIndicator(),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            competition.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      competition.country,
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      softWrap: true,
                    ),
                    const SizedBox(height: 4),
                    // Competition info list
                    _buildCompetitionInfoList(competition),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip:
                    isFavorite ? 'Remove from favorites' : 'Add to favorites',
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? const Color(0xFF002366) : Colors.grey,
                  size: 24,
                ),
                onPressed:
                    _updatingFavoriteIds.contains(competition.id)
                        ? null
                        : () => _toggleFavorite(competition),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        width: MediaQuery.of(context).size.width * 0.95,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.95),
              Colors.white.withValues(alpha: 0.9),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF002366).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.1),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildNavItem(0, Icons.sports_soccer, 'Matches'),
                    ),
                    Expanded(child: _buildNavItem(1, Icons.article, 'News')),
                    Expanded(
                      child: _buildNavItem(2, Icons.smart_toy, 'AI Quiz'),
                    ),
                    Expanded(
                      child: _buildNavItem(3, Icons.settings, 'Settings'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedTabIndex == index;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive font size based on screen width
    double fontSize;
    double iconSize;
    double spacing;

    if (screenWidth < 375) {
      // iPhone SE, small devices
      fontSize = 10;
      iconSize = 24;
      spacing = 2;
    } else if (screenWidth < 390) {
      // iPhone 12 mini, iPhone 13 mini
      fontSize = 11;
      iconSize = 26;
      spacing = 3;
    } else if (screenWidth < 430) {
      // iPhone 12/13/14/15, standard size
      fontSize = 12;
      iconSize = 28;
      spacing = 4;
    } else {
      // iPhone Plus/Pro Max, iPads
      fontSize = 13;
      iconSize = 30;
      spacing = 4;
    }

    return GestureDetector(
      onTap: () {
        // Show interstitial ad on tab switch
        if (index != _selectedTabIndex) {
          AdmobService().onTabSwitch();
        }
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth < 375 ? 8 : 12,
          vertical: screenWidth < 375 ? 6 : 8,
        ),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? const Color(0xFFFF4D00)
                      : const Color(0xFF002366),
              size: iconSize,
            ),
            SizedBox(height: spacing),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  color:
                      isSelected
                          ? const Color(0xFFFF4D00)
                          : const Color(0xFF002366),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: fontSize,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetitionInfoList(CompetitionWithMatches competition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Match count
        _buildInfoRow(
          Icons.sports_soccer,
          '${competition.matches.length} match${competition.matches.length > 1 ? 'es' : ''}',
          Colors.blue,
        ),
        const SizedBox(height: 4),
        // Next match time
        _buildInfoRow(
          Icons.access_time,
          'Next: ${_getNextMatchTime(competition.matches)}',
          const Color(0xFFFF4D00),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedLiveIndicator() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.7 + (value * 0.3)),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3 + (value * 0.2)),
                blurRadius: 2 + (value * 2),
                spreadRadius: value * 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                child: Icon(
                  Icons.fiber_manual_record,
                  size: 4 + (value * 1),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 1),
              Text(
                'LIVE',
                style: TextStyle(
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
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

  Widget _buildElegantBackground() {
    return const AppWallpaper();
  }
}

class CompetitionWithMatches {
  final int id;
  final String name;
  final String country;
  final String logo;
  final String flag;
  final List<Match> matches;

  CompetitionWithMatches({
    required this.id,
    required this.name,
    required this.country,
    required this.logo,
    required this.flag,
    required this.matches,
  });
}

class GalaxyBallsPainter extends CustomPainter {
  final double animationValue;

  GalaxyBallsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw football pitch background
    _drawFootballPitch(canvas, size, paint);

    // Draw moving soccer balls
    _drawMovingSoccerBalls(canvas, size, paint);

    // Draw floating particles (soccer balls)
    _drawFloatingParticles(canvas, size, paint);
  }

  void _drawFootballPitch(Canvas canvas, Size size, Paint paint) {
    // Draw football pitch background
    final pitchPaint =
        Paint()
          ..color = Colors.green.shade800.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;

    // Main pitch area
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pitchPaint);

    // Draw pitch lines
    paint.color = Colors.white.withValues(alpha: 0.6);
    paint.strokeWidth = 2.0;
    paint.style = PaintingStyle.stroke;

    // Center line (vertical)
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.15,
      paint,
    );

    // Goal areas (top and bottom)
    final goalAreaWidth = size.width * 0.3;
    final goalAreaHeight = size.height * 0.2;

    // Top goal area
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2 - goalAreaWidth / 2,
        0,
        goalAreaWidth,
        goalAreaHeight,
      ),
      paint,
    );

    // Bottom goal area
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2 - goalAreaWidth / 2,
        size.height - goalAreaHeight,
        goalAreaWidth,
        goalAreaHeight,
      ),
      paint,
    );

    // Draw players on the pitch
    _drawPlayers(canvas, size, paint);

    // Draw central soccer ball
    _drawCentralSoccerBall(canvas, size, paint);
  }

  void _drawPlayers(Canvas canvas, Size size, Paint paint) {
    // Team 1 players (left side - blue)
    final team1Players = [
      {'x': 0.15, 'y': 0.1}, // Goalkeeper
      {'x': 0.2, 'y': 0.3}, // Defender
      {'x': 0.18, 'y': 0.5}, // Midfielder
      {'x': 0.22, 'y': 0.7}, // Midfielder
      {'x': 0.25, 'y': 0.9}, // Forward
    ];

    // Team 2 players (right side - red)
    final team2Players = [
      {'x': 0.85, 'y': 0.1}, // Goalkeeper
      {'x': 0.8, 'y': 0.3}, // Defender
      {'x': 0.82, 'y': 0.5}, // Midfielder
      {'x': 0.78, 'y': 0.7}, // Midfielder
      {'x': 0.75, 'y': 0.9}, // Forward
    ];

    // Draw team 1 players (blue)
    paint.color = Colors.blue.withValues(alpha: 0.8);
    paint.style = PaintingStyle.fill;
    for (final player in team1Players) {
      final x = (player['x'] as double) * size.width;
      final y = (player['y'] as double) * size.height;
      canvas.drawCircle(Offset(x, y), 8, paint);

      // Player number
      paint.color = Colors.white;
      paint.style = PaintingStyle.fill;
      // Simple number representation with small circles
      canvas.drawCircle(Offset(x, y), 3, paint);
      paint.color = Colors.blue.withValues(alpha: 0.8);
    }

    // Draw team 2 players (red)
    paint.color = Colors.red.withValues(alpha: 0.8);
    paint.style = PaintingStyle.fill;
    for (final player in team2Players) {
      final x = (player['x'] as double) * size.width;
      final y = (player['y'] as double) * size.height;
      canvas.drawCircle(Offset(x, y), 8, paint);

      // Player number
      paint.color = Colors.white;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 3, paint);
      paint.color = Colors.red.withValues(alpha: 0.8);
    }
  }

  void _drawCentralSoccerBall(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final ballSize = 20.0;

    // Pulsing effect for the central ball
    final pulseSize = ballSize + (math.sin(animationValue * 4 * 3.14159) * 3);

    // Draw central soccer ball with rotation animation
    _drawRotatingSoccerBall(
      canvas,
      Offset(centerX, centerY),
      pulseSize,
      const Color(0xFFFF4D00),
      animationValue,
    );

    // Add glow effect around the central ball
    paint.color = const Color(
      0xFFFF4D00,
    ).withValues(alpha: 0.3 + (math.sin(animationValue * 2 * 3.14159) * 0.2));
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), pulseSize * 1.5, paint);
  }

  void _drawMovingSoccerBalls(Canvas canvas, Size size, Paint paint) {
    // Multiple soccer balls moving vertically across the pitch
    final balls = [
      {
        'x': 0.2,
        'y': 0.1,
        'size': 10.0,
        'speed': 0.4,
        'color': const Color(0xFFFF4D00),
      },
      {
        'x': 0.8,
        'y': 0.3,
        'size': 8.0,
        'speed': 0.6,
        'color': const Color(0xFFFF4D00).withValues(alpha: 0.8),
      },
      {
        'x': 0.3,
        'y': 0.6,
        'size': 12.0,
        'speed': 0.3,
        'color': const Color(0xFFFF4D00).withValues(alpha: 0.6),
      },
      {
        'x': 0.7,
        'y': 0.8,
        'size': 9.0,
        'speed': 0.5,
        'color': const Color(0xFFFF4D00).withValues(alpha: 0.4),
      },
    ];

    for (final ball in balls) {
      final baseX = ball['x'] as double;
      final baseY = ball['y'] as double;
      final ballSize = ball['size'] as double;
      final speed = ball['speed'] as double;
      final color = ball['color'] as Color;

      // Vertical movement with horizontal bobbing
      final x = baseX + math.sin(animationValue * 2 * 3.14159 * speed) * 0.1;
      final y = (baseY + animationValue * speed) % 1.0;

      final ballX = x * size.width;
      final ballY = y * size.height;

      _drawSoccerBall(
        canvas,
        Offset(ballX, ballY),
        ballSize,
        color,
        animationValue,
      );
    }
  }

  void _drawSoccerBall(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
    double animationValue,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Main soccer ball body
    paint.color = color.withValues(alpha: 0.8 + (animationValue * 0.2));
    canvas.drawCircle(center, size, paint);

    // Soccer ball pattern - pentagons
    paint.color = Colors.white.withValues(alpha: 0.6);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;

    // Draw pentagon pattern
    final pentagonSize = size * 0.3;
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * 3.14159 / 5) + animationValue;
      final x = center.dx + pentagonSize * math.cos(angle);
      final y = center.dy + pentagonSize * math.sin(angle);
      canvas.drawCircle(Offset(x, y), size * 0.1, paint);
    }

    // Center pentagon
    canvas.drawCircle(center, size * 0.15, paint);
  }

  void _drawRotatingSoccerBall(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
    double animationValue,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Main soccer ball body
    paint.color = color.withValues(alpha: 0.8 + (animationValue * 0.2));
    canvas.drawCircle(center, size, paint);

    // Soccer ball pattern with continuous rotation
    paint.color = Colors.white.withValues(alpha: 0.6);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;

    // Draw pentagon pattern with rotation
    final pentagonSize = size * 0.3;
    for (int i = 0; i < 5; i++) {
      final angle =
          (i * 2 * 3.14159 / 5) +
          (animationValue * 4 * 3.14159); // Faster rotation
      final x = center.dx + pentagonSize * math.cos(angle);
      final y = center.dy + pentagonSize * math.sin(angle);
      canvas.drawCircle(Offset(x, y), size * 0.1, paint);
    }

    // Center pentagon with rotation
    final centerAngle = animationValue * 6 * 3.14159; // Even faster rotation
    final centerX = center.dx + (size * 0.1) * math.cos(centerAngle);
    final centerY = center.dy + (size * 0.1) * math.sin(centerAngle);
    canvas.drawCircle(Offset(centerX, centerY), size * 0.15, paint);
  }

  void _drawFloatingParticles(Canvas canvas, Size size, Paint paint) {
    // Random floating soccer balls with different movements
    for (int i = 0; i < 8; i++) {
      final x = (i * 80.0 + animationValue * 100) % size.width;
      final y = (i * 60.0 + animationValue * 80) % size.height;
      final ballSize = 4.0 + (i % 3) * 2.0;

      // Different movement patterns
      final movementX = math.sin(animationValue * 2 * 3.14159 + i) * 20;
      final movementY = math.cos(animationValue * 1.5 * 3.14159 + i) * 15;

      final ballX = (x + movementX) % size.width;
      final ballY = (y + movementY) % size.height;

      // Twinkling effect
      final twinkle = (math.sin(animationValue * 3.14159 * 2 + i) + 1) / 2;
      final colors = [
        const Color(0xFFFF4D00),
        const Color(0xFFFF4D00).withValues(alpha: 0.8),
        const Color(0xFFFF4D00).withValues(alpha: 0.6),
        const Color(0xFFFF4D00).withValues(alpha: 0.4),
      ];
      final color = colors[i % colors.length];

      _drawSoccerBall(canvas, Offset(ballX, ballY), ballSize, color, twinkle);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Colorful Dots Painter for white background with floating dots
class ColorfulDotsPainter extends CustomPainter {
  final double animationValue;

  ColorfulDotsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

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
        const Color(0xFFFF9F43), // Orange
        const Color(0xFF00D2D3), // Cyan
      ];

      final color = colors[i % colors.length];

      // Add twinkling effect
      final twinkle = (math.sin(animationValue * 3 * 3.14159 + i) + 1) / 2;
      final alpha = 0.6 + twinkle * 0.4;

      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(dotX, dotY), dotSize, paint);

      // Add subtle glow effect
      paint.color = color.withValues(alpha: 0.1);
      canvas.drawCircle(Offset(dotX, dotY), dotSize * 2.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Elegant Particles Painter for glassmorphism background
class ElegantParticlesPainter extends CustomPainter {
  final double animationValue;

  ElegantParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw floating particles with glassmorphism effect
    _drawFloatingParticles(canvas, size, paint);
    _drawGlowingOrbs(canvas, size, paint);
    _drawGradientWaves(canvas, size, paint);
  }

  void _drawFloatingParticles(Canvas canvas, Size size, Paint paint) {
    // Create elegant floating particles
    for (int i = 0; i < 15; i++) {
      final x = (i * 120.0 + animationValue * 80) % size.width;
      final y = (i * 80.0 + animationValue * 60) % size.height;
      final particleSize = 2.0 + (i % 4) * 1.5;

      // Different movement patterns for elegance
      final movementX = math.sin(animationValue * 1.5 * 3.14159 + i) * 30;
      final movementY = math.cos(animationValue * 2 * 3.14159 + i) * 25;

      final particleX = (x + movementX) % size.width;
      final particleY = (y + movementY) % size.height;

      // Glassmorphism particle effect
      final twinkle = (math.sin(animationValue * 4 * 3.14159 + i) + 1) / 2;
      final colors = [
        Colors.white.withValues(alpha: 0.3 + twinkle * 0.4),
        Colors.cyan.withValues(alpha: 0.2 + twinkle * 0.3),
        Colors.blue.withValues(alpha: 0.25 + twinkle * 0.35),
        Colors.purple.withValues(alpha: 0.2 + twinkle * 0.3),
      ];
      final color = colors[i % colors.length];

      paint.color = color;
      canvas.drawCircle(Offset(particleX, particleY), particleSize, paint);

      // Add glow effect
      paint.color = color.withValues(alpha: 0.1);
      canvas.drawCircle(
        Offset(particleX, particleY),
        particleSize * 2.5,
        paint,
      );
    }
  }

  void _drawGlowingOrbs(Canvas canvas, Size size, Paint paint) {
    // Create larger glowing orbs for depth
    final orbs = [
      {'x': 0.2, 'y': 0.3, 'size': 40.0, 'speed': 0.3, 'color': Colors.cyan},
      {'x': 0.8, 'y': 0.7, 'size': 35.0, 'speed': 0.4, 'color': Colors.purple},
      {'x': 0.6, 'y': 0.2, 'size': 30.0, 'speed': 0.5, 'color': Colors.blue},
      {'x': 0.3, 'y': 0.8, 'size': 45.0, 'speed': 0.2, 'color': Colors.indigo},
    ];

    for (final orb in orbs) {
      final baseX = orb['x'] as double;
      final baseY = orb['y'] as double;
      final orbSize = orb['size'] as double;
      final speed = orb['speed'] as double;
      final color = orb['color'] as Color;

      // Gentle floating movement
      final x = baseX + math.sin(animationValue * 2 * 3.14159 * speed) * 0.1;
      final y = baseY + math.cos(animationValue * 1.5 * 3.14159 * speed) * 0.1;

      final orbX = x * size.width;
      final orbY = y * size.height;

      // Outer glow
      paint.color = color.withValues(alpha: 0.1);
      canvas.drawCircle(Offset(orbX, orbY), orbSize * 2, paint);

      // Inner glow
      paint.color = color.withValues(alpha: 0.2);
      canvas.drawCircle(Offset(orbX, orbY), orbSize * 1.2, paint);

      // Core
      paint.color = color.withValues(alpha: 0.3);
      canvas.drawCircle(Offset(orbX, orbY), orbSize * 0.6, paint);
    }
  }

  void _drawGradientWaves(Canvas canvas, Size size, Paint paint) {
    // Create subtle wave patterns
    final waveCount = 3;
    for (int i = 0; i < waveCount; i++) {
      final waveY =
          (i * size.height / waveCount) +
          (math.sin(animationValue * 2 * 3.14159 + i) * 20);
      final waveHeight = 2.0 + math.sin(animationValue * 3 * 3.14159 + i) * 1.0;

      paint.color = Colors.white.withValues(
        alpha: 0.05 + (math.sin(animationValue * 4 * 3.14159 + i) * 0.05),
      );
      paint.strokeWidth = waveHeight;
      paint.style = PaintingStyle.stroke;

      final path = Path();
      for (double x = 0; x < size.width; x += 5) {
        final y =
            waveY +
            math.sin(
                  (x / size.width) * 4 * 3.14159 + animationValue * 2 * 3.14159,
                ) *
                15;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
