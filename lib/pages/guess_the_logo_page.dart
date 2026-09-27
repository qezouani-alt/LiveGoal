import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;
import '../main.dart' as main_app;

class GuessTheLogoPage extends StatefulWidget {
  const GuessTheLogoPage({super.key});

  @override
  State<GuessTheLogoPage> createState() => _GuessTheLogoPageState();
}

class _GuessTheLogoPageState extends State<GuessTheLogoPage> {
  final TextEditingController _answerController = TextEditingController();
  final List<ClubLogoData> _clubs = [];

  ClubLogoData? _currentClub;
  int _currentClueIndex = 0;
  bool _answerChecked = false;
  bool _isCorrect = false;
  int _wrongAttempts = 0;

  @override
  void initState() {
    super.initState();
    _loadClubs();
    _answerController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadClubs() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/logos.json');
      final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
      final loaded = data
          .map((e) => ClubLogoData.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _clubs
          ..clear()
          ..addAll(loaded);
      });
      _loadRandomClub();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _clubs.addAll([
          ClubLogoData(
            name: 'FC Barcelona',
            league: 'La Liga',
            city: 'Barcelona',
            colors: ['blue', 'garnet', 'yellow'],
            hint: 'Famous for La Masia academy',
            logoClues: [
              'Shield divided with cross of Saint George and Catalan stripes.',
              'Blue and garnet stripes in the lower half.',
              'A central football in the lower section.',
              'Abbreviation letters appear across the middle ribbon.',
            ],
          ),
          ClubLogoData(
            name: 'Juventus',
            league: 'Serie A',
            city: 'Turin',
            colors: ['black', 'white'],
            hint: 'Old Lady',
            logoClues: [
              'Minimal modern crest introduced in 2017.',
              'Stylized letter that echoes the club initial repeated.',
              'Black and white colorway only.',
              'Represents the stripes of the shirt and a scudetto silhouette.',
            ],
          ),
        ]);
      });
      _loadRandomClub();
    }
  }

  void _loadRandomClub() {
    if (_clubs.isEmpty) return;
    setState(() {
      _currentClub = _clubs[math.Random().nextInt(_clubs.length)];
      _currentClueIndex = 0;
      _answerChecked = false;
      _isCorrect = false;
      _wrongAttempts = 0;
      _answerController.clear();
    });
  }

  void _checkAnswer() {
    if (_answerController.text.trim().isEmpty || _currentClub == null) return;
    final guess = _answerController.text.trim().toLowerCase();
    final correct = _currentClub!.name.toLowerCase();
    setState(() {
      _answerChecked = true;
      _isCorrect = guess == correct;
      if (!_isCorrect) _wrongAttempts += 1;
    });
  }

  void _retry() {
    setState(() {
      _answerChecked = false;
      _isCorrect = false;
      _answerController.clear();
    });
  }

  void _showHintDialog() {
    if (_currentClub == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: const Color(0xFF002366), size: 24),
            const SizedBox(width: 8),
            const Text('Hint'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('League: ${_currentClub!.league}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('City: ${_currentClub!.city}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Colors: ${_currentClub!.colors.join(', ')}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text('Hint: ${_currentClub!.hint}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF002366),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showCharacterHint() {
    if (_currentClub == null) return;
    
    final name = _currentClub!.name;
    final firstChar = name.isNotEmpty ? name[0] : '';
    final lastChar = name.length > 1 ? name[name.length - 1] : '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Character Hint',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Here are the first and last characters:',
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCharacterBox(firstChar, 'First'),
                  const SizedBox(width: 20),
                  const Text(
                    '...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 20),
                  _buildCharacterBox(lastChar, 'Last'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it!',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterBox(String character, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              character,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Guess the Logo',
            style: TextStyle(
              color: Color(0xFF002366),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildElegantBackground(),
          LayoutBuilder(
            builder: (context, constraints) {
              final double topSafeSpace = 80;
              final double minHeight = math.max(0, constraints.maxHeight - topSafeSpace);
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Padding(
                    padding: EdgeInsets.only(top: topSafeSpace),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildClueCard(),
                          const SizedBox(height: 20),
                          _buildAnswerInput(),
                          const SizedBox(height: 20),
                          _buildActions(),
                          const SizedBox(height: 20),
                          if (_answerChecked) _buildResult(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClueCard() {
    final clues = _currentClub?.logoClues ?? const <String>[];
    final hasMore = _currentClueIndex < (clues.length - 1);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_emotions, color: const Color(0xFF002366), size: 20),
              const SizedBox(width: 8),
              Text('Logo Description',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002366),
                  )),
              const Spacer(),
              Text('Clue ${clues.isEmpty ? 0 : _currentClueIndex + 1}/${clues.length}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            ],
          ),
          const SizedBox(height: 12),
          Text(clues.isEmpty ? 'Loading…' : clues[_currentClueIndex],
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: hasMore ? () => setState(() => _currentClueIndex++) : null,
              icon: const Icon(Icons.redo, size: 18),
              label: const Text('Reveal next clue'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF002366),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Text('Which club uses this logo?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF002366),
              )),
          const SizedBox(height: 16),
          TextFormField(
            controller: _answerController,
            enabled: !_answerChecked,
            decoration: InputDecoration(
              hintText: 'Enter club name…',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: const Color(0xFF002366).withValues(alpha: 0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF002366), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _wrongAttempts > 0 ? _showHintDialog : null,
              icon: const Icon(Icons.lightbulb_outline, size: 20),
              label: const Text('Hint'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _answerController.text.trim().isNotEmpty && !_answerChecked ? _checkAnswer : null,
              icon: const Icon(Icons.check, size: 20),
              label: const Text('Check'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isCorrect ? Colors.green : Colors.red, width: 2),
      ),
      child: Column(
        children: [
          Icon(_isCorrect ? Icons.check_circle : Icons.cancel,
              color: _isCorrect ? Colors.green : Colors.red, size: 40),
          const SizedBox(height: 8),
          Text(_isCorrect ? 'Correct!' : 'Incorrect',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isCorrect ? Colors.green : Colors.red,
              )),
          const SizedBox(height: 16),
          if (_isCorrect) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadRandomClub,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Next Club'),
              ),
            ),
          ] else if (!_isCorrect && _wrongAttempts == 1) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _retry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Try again'),
                  ),
                ),
              ],
            ),
          ] else if (!_isCorrect && _wrongAttempts >= 2) ...[
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _retry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Try again'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loadRandomClub,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4D00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Skip this club'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showCharacterHint,
                    icon: const Icon(Icons.text_fields, size: 20),
                    label: const Text('Show First & Last Character'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
            painter: main_app.ColorfulDotsPainter(value),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class ClubLogoData {
  final String name;
  final String league;
  final String city;
  final List<String> colors;
  final String hint;
  final List<String> logoClues;

  ClubLogoData({
    required this.name,
    required this.league,
    required this.city,
    required this.colors,
    required this.hint,
    required this.logoClues,
  });

  factory ClubLogoData.fromJson(Map<String, dynamic> json) {
    return ClubLogoData(
      name: (json['name'] ?? '').toString(),
      league: (json['league'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      colors: (json['colors'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[],
      hint: (json['hint'] ?? '').toString(),
      logoClues: (json['logoClues'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[],
    );
  }
}
