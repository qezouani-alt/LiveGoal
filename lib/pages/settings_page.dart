import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';
import '../widgets/app_brand_image.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static final Uri _appStoreUrl = Uri.parse(
    'https://apps.apple.com/app/id6816469499',
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated Background
        _buildElegantBackground(),
        // Main Content
        SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              // Content
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        width: MediaQuery.of(context).size.width * 0.99,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, color: const Color(0xFF002366), size: 24),
            const SizedBox(width: 12),
            Text(
              "Settings",
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

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: 100,
      ), // Add bottom padding to prevent overlap with tabview
      child: Column(
        children: [
          // App Info Section
          _buildAppInfoSection(),
          // About Section
          _buildAboutSection(),
          // Support Section
          _buildSupportSection(),
          // Legal Section
          _buildLegalSection(),
          const SizedBox(height: 20),
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

  Widget _buildAppInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          // App Icon and Name
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const AppBrandImage(size: 60, borderRadius: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LiveGoal AI',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Your Ultimate Football Companion',
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // App Version
          _buildAppVersion(),
        ],
      ),
    );
  }

  Widget _buildAppVersion() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'LiveGoal AI is your ultimate football companion, providing real-time match updates, AI-powered insights, comprehensive football news, an intelligent AI assistant, and enjoyable quizzes. Stay connected with the beautiful game like never before.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_agent, color: Colors.green.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                'Support',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSupportItem(
            icon: Icons.email,
            title: 'Contact Us',
            subtitle: 'Get in touch with our team',
            onTap: _openContactEmail,
          ),
          const SizedBox(height: 12),
          Builder(
            builder:
                (buttonContext) => _buildSupportItem(
                  icon: Icons.share,
                  title: 'Share App',
                  subtitle: 'Tell your friends about LiveGoal AI',
                  onTap: () => _shareApp(buttonContext),
                ),
          ),
          const SizedBox(height: 12),
          _buildSupportItem(
            icon: Icons.star_rate,
            title: 'Rate Now',
            subtitle: 'Review LiveGoal AI on the App Store',
            onTap: _rateApp,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel, color: const Color(0xFFFF4D00), size: 24),
              const SizedBox(width: 12),
              Text(
                'Legal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSupportItem(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'How we protect your data',
            onTap: _openPrivacyPolicy,
          ),
        ],
      ),
    );
  }

  void _openContactEmail() async {
    const email = 'fadma01x@gmail.com';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=LiveGoal AI Support',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    final box = context.findRenderObject()! as RenderBox;
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Check out LiveGoal AI for live football scores, news, and more! ⚽\n\n$_appStoreUrl',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  Future<void> _rateApp() async {
    final reviewUrl = _appStoreUrl.replace(
      queryParameters: {'action': 'write-review'},
    );
    await launchUrl(reviewUrl, mode: LaunchMode.externalApplication);
  }

  void _openPrivacyPolicy() async {
    final uri = Uri.parse(
      'https://livegoalai.blogspot.com/2026/09/blog-post.html',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// Galaxy Balls Painter for animated background
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
