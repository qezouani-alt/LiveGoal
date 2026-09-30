import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api_football_service.dart';
import '../services/admob_service.dart';
import '../main.dart';
import 'match_details_page.dart';

class CompetitionMatchesPage extends StatefulWidget {
  final CompetitionWithMatches competition;

  const CompetitionMatchesPage({super.key, required this.competition});

  @override
  State<CompetitionMatchesPage> createState() => _CompetitionMatchesPageState();
}

class _CompetitionMatchesPageState extends State<CompetitionMatchesPage> {
  CompetitionWithMatches get competition => widget.competition;
  bool _isReturning = false;

  Future<void> _returnToMatches() async {
    if (_isReturning) return;
    _isReturning = true;
    await AdmobService().showInterstitialAdAndWait();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF002366)),
          onPressed: _returnToMatches,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              competition.name,
              style: const TextStyle(
                color: Color(0xFF002366),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
            ),
            Text(
              '${competition.country} • ${competition.matches.length} match${competition.matches.length > 1 ? 'es' : ''}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // White Background with Colorful Dots
          _buildElegantBackground(),
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom:
                    20, // Add extra bottom padding to prevent content hiding under tabview
              ),
              child: Column(
                children: [
                  // Competition Header Card
                  _buildCompetitionHeader(),

                  const SizedBox(height: 16),

                  // Matches List (sorted by time)
                  ...(_sortMatchesByTime(
                    competition.matches,
                  )).map((match) => _buildMatchCard(match, context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Match> _sortMatchesByTime(List<Match> matches) {
    List<Match> sortedMatches = List.from(matches);

    sortedMatches.sort((a, b) {
      // First, sort by status priority (live matches first, then upcoming, then finished)
      int statusPriorityA = _getStatusPriority(a.status);
      int statusPriorityB = _getStatusPriority(b.status);

      if (statusPriorityA != statusPriorityB) {
        return statusPriorityA.compareTo(statusPriorityB);
      }

      // Then sort by time
      try {
        // Convert time string to comparable format (HH:MM)
        String timeA = a.time == 'TBD' ? '99:99' : a.time;
        String timeB = b.time == 'TBD' ? '99:99' : b.time;

        return timeA.compareTo(timeB);
      } catch (e) {
        // If time parsing fails, keep original order
        return 0;
      }
    });

    return sortedMatches;
  }

  int _getStatusPriority(String status) {
    switch (status.toUpperCase()) {
      case 'LIVE':
      case '1H':
      case '2H':
      case 'HT':
        return 0; // Live matches first
      case 'NS':
      case 'TBD':
        return 1; // Upcoming matches second
      case 'FT':
      case 'AET':
      case 'PEN':
        return 2; // Finished matches third
      case 'CANC':
      case 'SUSP':
      case 'PST':
        return 3; // Cancelled/postponed matches last
      default:
        return 1; // Default to upcoming
    }
  }

  Widget _buildElegantBackground() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 8),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: CustomPaint(
            painter: ColorfulDotsPainter(value),
            size: Size.infinite,
          ),
        );
      },
      onEnd: () {
        // Animation completed, will restart automatically
      },
    );
  }

  Widget _buildCompetitionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                competition.logo,
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
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
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 24,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          competition.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  competition.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      competition.country,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${competition.matches.length} match${competition.matches.length > 1 ? 'es' : ''} today',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(Match match, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailsPage(match: match),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF002366).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF002366).withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Match Time and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  match.time,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(match.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(match.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Teams and Score
            Row(
              children: [
                // Home Team
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            match.homeTeam.logo,
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
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.sports_soccer,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    Text(
                                      match.homeTeam.name
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.homeTeam.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Score
                Expanded(
                  child: Column(
                    children: [
                      if (match.score != null) ...[
                        Text(
                          '${match.score!.home} - ${match.score!.away}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Away Team
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            match.awayTeam.logo,
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
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.sports_soccer,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    Text(
                                      match.awayTeam.name
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.awayTeam.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (match.venue.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stadium, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    match.venue,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'LIVE':
      case '1H':
      case '2H':
        return Colors.red;
      case 'FT':
      case 'AET':
      case 'PEN':
        return Colors.green;
      case 'HT':
        return Colors.orange;
      case 'CANC':
      case 'SUSP':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'NS':
        return 'Not Started';
      case 'LIVE':
        return 'LIVE';
      case '1H':
        return '1st Half';
      case '2H':
        return '2nd Half';
      case 'HT':
        return 'Half Time';
      case 'FT':
        return 'Full Time';
      case 'AET':
        return 'Extra Time';
      case 'PEN':
        return 'Penalties';
      case 'CANC':
        return 'Cancelled';
      case 'SUSP':
        return 'Suspended';
      default:
        return status;
    }
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
