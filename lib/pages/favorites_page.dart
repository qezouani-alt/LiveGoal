import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foot/models/favorite_competition.dart';
import 'package:foot/services/favorites_service.dart';
import 'package:foot/services/api_football_service.dart';
import 'package:foot/main.dart' as main_app;
import 'package:foot/pages/competition_matches_page.dart';

class CompetitionWithMatches {
  final int id;
  final String name;
  final String country;
  final String logo;
  final List<Match> matches;

  CompetitionWithMatches({
    required this.id,
    required this.name,
    required this.country,
    required this.logo,
    required this.matches,
  });
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with TickerProviderStateMixin {
  List<CompetitionWithMatches> _favoriteCompetitions = [];
  final bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavoriteCompetitions();
  }

  Future<void> _loadFavoriteCompetitions() async {
    if (mounted) {
    setState(() {
        _errorMessage = null;
      });
    }

    try {
      final favoriteCompetitions = await FavoritesService.getFavoriteCompetitions();
      final competitions = <CompetitionWithMatches>[];

      for (final favorite in favoriteCompetitions) {
        try {
          // Get today's matches for this competition
          final today = DateTime.now();
          final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
          final matches = await ApiFootballService.getMatchesByDate(dateString);
          
          // Filter matches for this competition
          final competitionMatches = matches.where((match) => match.league.id == favorite.id).toList();
          
          if (competitionMatches.isNotEmpty) {
            final competition = CompetitionWithMatches(
              id: favorite.id,
              name: favorite.name,
              country: favorite.country,
              logo: favorite.logo,
              matches: competitionMatches,
            );
            competitions.add(competition);
          }
        } catch (e) {
          // Skip competitions that can't be loaded
          continue;
        }
      }

      if (mounted) {
      setState(() {
          _favoriteCompetitions = competitions;
      });
      }
    } catch (e) {
      if (mounted) {
      setState(() {
          _errorMessage = e.toString();
      });
      }
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
          // Main Content
          SafeArea(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.99,
                child: _buildBody(),
              ),
            ),
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
            painter: main_app.ColorfulDotsPainter(value),
            size: Size.infinite,
          ),
        );
      },
      onEnd: () {
        // Animation completed, will restart automatically
      },
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadFavoriteCompetitions,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  
                  if (_errorMessage != null) ...[
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
              'Error loading favorites',
                              style: TextStyle(
                                fontSize: 16,
                fontWeight: FontWeight.w500,
                                color: const Color(0xFFFF4D00).withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                fontSize: 14,
                                color: Colors.grey[600],
                              ),
            ),
          ],
        ),
      ),
                    ),
                  ] else if (_favoriteCompetitions.isEmpty) ...[
                    Center(
          child: Container(
                        margin: const EdgeInsets.all(32),
                        padding: const EdgeInsets.all(24),
                        height: 200, // Add specific height for proper vertical centering
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                              Icons.favorite_border,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                                  Text(
                              'No favorite competitions',
                              textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add competitions to your favorites to see them here',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                    ),
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

          // Favorite Competitions List
          if (!_isLoading && _errorMessage == null && _favoriteCompetitions.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                  return _buildFavoriteCompetitionItem(_favoriteCompetitions[index]);
              },
                childCount: _favoriteCompetitions.length,
            ),
          ),

          // Bottom padding to prevent content hiding under tabview
          SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
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
              Icons.favorite,
              color: const Color(0xFF002366),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              "Favorite Competitions (${_favoriteCompetitions.length})",
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
    );
  }

  Widget _buildFavoriteCompetitionItem(CompetitionWithMatches competition) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        width: MediaQuery.of(context).size.width * 0.99,
        child: GestureDetector(
          onTap: () {
            // Convert local CompetitionWithMatches to main.dart CompetitionWithMatches
            final mainCompetition = main_app.CompetitionWithMatches(
            id: competition.id,
            name: competition.name,
            country: competition.country,
            logo: competition.logo,
              flag: competition.logo, // Use logo as flag for now
              matches: competition.matches,
          );
            
            // Navigate to competition details page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompetitionMatchesPage(competition: mainCompetition),
              ),
            );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF002366).withValues(alpha: 0.4), width: 2),
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
                  width: 48,
                  height: 48,
              decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  competition.logo,
                      width: 48,
                      height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                          width: 48,
                          height: 48,
                      decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.sports_soccer,
                            color: Colors.grey.shade400,
                            size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    competition.name,
                    style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                    ),
                  ),
                      const SizedBox(height: 4),
                  Text(
                    competition.country,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
      children: [
                          Icon(
          Icons.sports_soccer,
                            size: 16,
                            color: Colors.blue.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${competition.matches.length} matches',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
            ),
          ),
      ],
                      ),
                      const SizedBox(height: 2),
                      Row(
      children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: const Color(0xFFFF4D00),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Next: LIVE',
                            style: const TextStyle(
              fontSize: 12,
                              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
          ),
        ),
      ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Favorite toggle button
                FutureBuilder<bool>(
                  future: FavoritesService.isFavorite(competition.id),
                  builder: (context, snapshot) {
                    final isFavorite = snapshot.data ?? false;
    return GestureDetector(
                      onTap: () async {
                        if (isFavorite) {
                          await FavoritesService.removeFromFavorites(competition.id);
                          // Reload favorites to remove the competition from the list
                          _loadFavoriteCompetitions();
                        } else {
                          await FavoritesService.addToFavorites(
                            FavoriteCompetition(
                              id: competition.id,
                              name: competition.name,
                              country: competition.country,
                              logo: competition.logo,
                            ),
                          );
                          setState(() {});
                        }
      },
      child: Container(
                        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
                          color: isFavorite ? const Color(0xFFFF4D00).withValues(alpha: 0.2) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Galaxy Balls Painter for animated background
class GalaxyBallsPainter extends CustomPainter {
  final double animationValue;

  GalaxyBallsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw football pitch background
    _drawFootballPitch(canvas, size, paint);
    
    // Draw moving soccer balls
    _drawMovingSoccerBalls(canvas, size, paint);
    
    // Draw floating particles (soccer balls)
    _drawFloatingParticles(canvas, size, paint);
  }

  void _drawFootballPitch(Canvas canvas, Size size, Paint paint) {
    // Draw football pitch background
    final pitchPaint = Paint()
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
      Rect.fromLTWH(size.width / 2 - goalAreaWidth / 2, 0, goalAreaWidth, goalAreaHeight),
      paint,
    );
    
    // Bottom goal area
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2 - goalAreaWidth / 2, size.height - goalAreaHeight, goalAreaWidth, goalAreaHeight),
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
      {'x': 0.2, 'y': 0.3},  // Defender
      {'x': 0.18, 'y': 0.5}, // Midfielder
      {'x': 0.22, 'y': 0.7}, // Midfielder
      {'x': 0.25, 'y': 0.9}, // Forward
    ];
    
    // Team 2 players (right side - red)
    final team2Players = [
      {'x': 0.85, 'y': 0.1}, // Goalkeeper
      {'x': 0.8, 'y': 0.3},  // Defender
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
    _drawRotatingSoccerBall(canvas, Offset(centerX, centerY), pulseSize, const Color(0xFFFF4D00), animationValue);
    
    // Add glow effect around the central ball
    paint.color = const Color(0xFFFF4D00).withValues(alpha: 0.3 + (math.sin(animationValue * 2 * 3.14159) * 0.2));
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), pulseSize * 1.5, paint);
  }

  void _drawMovingSoccerBalls(Canvas canvas, Size size, Paint paint) {
    // Multiple soccer balls moving vertically across the pitch
    final balls = [
      {'x': 0.2, 'y': 0.1, 'size': 10.0, 'speed': 0.4, 'color': const Color(0xFFFF4D00)},
      {'x': 0.8, 'y': 0.3, 'size': 8.0, 'speed': 0.6, 'color': const Color(0xFFFF4D00).withValues(alpha: 0.8)},
      {'x': 0.3, 'y': 0.6, 'size': 12.0, 'speed': 0.3, 'color': const Color(0xFFFF4D00).withValues(alpha: 0.6)},
      {'x': 0.7, 'y': 0.8, 'size': 9.0, 'speed': 0.5, 'color': const Color(0xFFFF4D00).withValues(alpha: 0.4)},
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
      
      _drawSoccerBall(canvas, Offset(ballX, ballY), ballSize, color, animationValue);
    }
  }

  void _drawSoccerBall(Canvas canvas, Offset center, double size, Color color, double animationValue) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

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

  void _drawRotatingSoccerBall(Canvas canvas, Offset center, double size, Color color, double animationValue) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

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
      final angle = (i * 2 * 3.14159 / 5) + (animationValue * 4 * 3.14159); // Faster rotation
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
      final colors = [const Color(0xFFFF4D00), const Color(0xFFFF4D00).withValues(alpha: 0.8), const Color(0xFFFF4D00).withValues(alpha: 0.6), const Color(0xFFFF4D00).withValues(alpha: 0.4)];
      final color = colors[i % colors.length];
      
      _drawSoccerBall(canvas, Offset(ballX, ballY), ballSize, color, twinkle);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}