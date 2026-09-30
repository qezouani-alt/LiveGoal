import 'package:flutter/material.dart';
import '../main.dart' as main_app;
import 'guess_the_stadium_page.dart';
import 'guess_the_logo_page.dart';
import 'guess_the_player_page.dart';
import 'guess_the_year_page.dart';
import 'fast_challenge_page.dart';
import 'ai_assistant_page.dart';

class AISearchPage extends StatefulWidget {
  const AISearchPage({super.key});

  @override
  State<AISearchPage> createState() => _AISearchPageState();
}

class _AISearchPageState extends State<AISearchPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated Background
        _buildElegantBackground(),
        // Main Content
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // Header
              _buildHeader(),
              
              // Game Modes Section
              _buildGameModesSection(),
                      ],
                    ),
                  ),
      ],
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // AI Title
            Text(
              "AI",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002366),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "AI QUIZ",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameModesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        children: [
          // AI Assistant Button
          _buildGameModeCard(
            title: 'AI Assistant',
            subtitle: 'Chat with our football AI',
            icon: Icons.psychology,
            emoji: '🤖',
            gradient: const LinearGradient(
              colors: [Color(0xFF002366), Color(0xFF4A90E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AIAssistantPage()),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Quiz Section Title
          Text(
            'QUIZ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002366),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Test your football knowledge',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Quiz Cards
          Column(
            children: [
              // Guess the Player Card
              _buildGameModeCard(
                title: 'Guess the Player',
                subtitle: 'Identify football players',
                icon: Icons.person,
                emoji: '⚽',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4D00), Color(0xFFFF8A65)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GuessThePlayerPage()),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Guess Club Logo Card
              _buildGameModeCard(
                title: 'Guess Club Logo',
                subtitle: 'Identify football club logos',
                icon: Icons.emoji_events,
                emoji: '🏆',
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GuessTheLogoPage()),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Guess the Stadium Card
              _buildGameModeCard(
                title: 'Guess the Stadium',
                subtitle: 'Identify football stadiums',
                icon: Icons.location_on,
                emoji: '🏟️',
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GuessTheStadiumPage()),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Fast Challenge Card
              _buildGameModeCard(
                title: 'Fast Challenge',
                subtitle: 'Time Attack mode',
                icon: Icons.timer,
                emoji: '⏱️',
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFFF06292)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FastChallengePage()),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Guess the Year Card
              _buildGameModeCard(
                title: 'Guess the Year',
                subtitle: 'Identify football events by year',
                icon: Icons.calendar_today,
                emoji: '🎯',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GuessTheYearPage()),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String emoji,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          width: MediaQuery.of(context).size.width * 0.95,
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
              // Icon Container
          Container(
                width: 40,
                height: 40,
            decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                      title,
                      style: const TextStyle(
                    fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
              
              const SizedBox(width: 8),
              
              // Arrow Icon
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ],
          ),
        ),
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
}