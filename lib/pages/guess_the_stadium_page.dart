import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../main.dart' as main_app;

class GuessTheStadiumPage extends StatefulWidget {
  const GuessTheStadiumPage({super.key});

  @override
  State<GuessTheStadiumPage> createState() => _GuessTheStadiumPageState();
}

class _GuessTheStadiumPageState extends State<GuessTheStadiumPage> {
  final TextEditingController _answerController = TextEditingController();
  final List<StadiumData> _stadiums = [];

  StadiumData? _currentStadium;
  bool _answerChecked = false;
  bool _isCorrect = false;
  int _currentClueIndex = 0;
  int _wrongAttempts = 0;

  @override
  void initState() {
    super.initState();
    _loadStadiums();
    // Rebuild when the user types so the Check button enable state updates
    _answerController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadStadiums() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/stadiums.json');
      final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
      final loaded = data.map((e) => StadiumData.fromJson(e as Map<String, dynamic>)).toList();
      if (mounted) {
        setState(() {
          _stadiums
            ..clear()
            ..addAll(loaded);
        });
        _loadRandomStadium();
      }
    } catch (_) {
      // Fallback to a minimal built-in dataset
      if (mounted) {
        setState(() {
          _stadiums.addAll([
            StadiumData(
              name: 'Camp Nou',
              city: 'Barcelona',
              team: 'FC Barcelona',
              imageUrl: '',
              hint: 'Home of Messi\'s former team',
              historyClues: [
                'Opened in 1957 and expanded several times during the 20th century.',
                'Its capacity once exceeded 120,000 before all-seater regulations.',
                'Hosted European finals and countless El Clásicos.',
                'Located in the Les Corts area of Barcelona.'
              ],
            ),
            StadiumData(
              name: 'Old Trafford',
              city: 'Manchester',
              team: 'Manchester United',
              imageUrl: '',
              hint: 'Theatre of Dreams',
              historyClues: [
                'Opened in 1910 and rebuilt after heavy damage in World War II.',
                'Nicknamed the Theatre of Dreams.',
                'Record domestic attendances before all-seater rules.',
                'Located in Greater Manchester, in Old Trafford.'
              ],
            ),
          ]);
        });
        _loadRandomStadium();
      }
    }
  }

  void _loadRandomStadium() {
    setState(() {
      _currentStadium = _stadiums[math.Random().nextInt(_stadiums.length)];
      _answerChecked = false;
      _isCorrect = false;
      _answerController.clear();
      _currentClueIndex = 0;
      _wrongAttempts = 0;
    });
  }

  void _checkAnswer() {
    if (_answerController.text.trim().isEmpty) return;
    
    setState(() {
      _answerChecked = true;
      _isCorrect = _answerController.text.trim().toLowerCase() == _currentStadium!.name.toLowerCase();
      if (!_isCorrect) {
        _wrongAttempts += 1;
      }
    });
  }

  void _retryCurrent() {
    setState(() {
      _answerChecked = false;
      _isCorrect = false;
      _answerController.clear();
    });
  }

  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: const Color(0xFF002366),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Hint'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'City: ${_currentStadium!.city}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Team: ${_currentStadium!.team}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Hint: ${_currentStadium!.hint}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF002366),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showCharacterHint() {
    if (_currentStadium == null) return;
    
    final name = _currentStadium!.name;
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
        title: Text(
          'Guess the Stadium',
          style: TextStyle(
            color: const Color(0xFF002366),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Animated Background
          _buildElegantBackground(),
          // Main Content
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
                          _buildActionButtons(),
                          const SizedBox(height: 20),
                          if (_answerChecked) _buildResultDisplay(),
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

  // Score/attempt/accuracy removed per request.

  // _buildStadiumImage removed (image mode deprecated in current design).

  Widget _buildClueCard() {
    final clues = _currentStadium?.historyClues ?? const <String>[];
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
              Icon(Icons.menu_book, color: const Color(0xFF002366), size: 20),
              const SizedBox(width: 8),
              Text(
                'Stadium Biography',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002366),
                ),
              ),
              const Spacer(),
              Text('Clue ${clues.isEmpty ? 0 : _currentClueIndex + 1}/${clues.length}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            clues.isEmpty ? 'Loading…' : clues[_currentClueIndex],
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
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
          Text(
            'What is the name of this stadium?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF002366),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _answerController,
            enabled: !_answerChecked,
            decoration: InputDecoration(
              hintText: 'Enter stadium name...',
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

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Hint Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _wrongAttempts > 0 ? _showHintDialog : null,
              icon: const Icon(Icons.lightbulb_outline, size: 20),
              label: const Text('Hint'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Check Answer Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _answerController.text.trim().isNotEmpty && !_answerChecked ? _checkAnswer : null,
              icon: const Icon(Icons.check, size: 20),
              label: const Text('Check'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _isCorrect ? Icons.check_circle : Icons.cancel,
            color: _isCorrect ? Colors.green : Colors.red,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            _isCorrect ? 'Correct!' : 'Incorrect',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _isCorrect ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          if (_isCorrect) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadRandomStadium,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Next Stadium'),
              ),
            ),
          ] else if (!_isCorrect && _wrongAttempts == 1) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _retryCurrent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                        onPressed: _retryCurrent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Try again'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loadRandomStadium,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4D00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Skip this stadium'),
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

class StadiumData {
  final String name;
  final String city;
  final String team;
  final String imageUrl;
  final String hint;
  final List<String> historyClues;

  StadiumData({
    required this.name,
    required this.city,
    required this.team,
    required this.imageUrl,
    required this.hint,
    required this.historyClues,
  });

  factory StadiumData.fromJson(Map<String, dynamic> json) {
    return StadiumData(
      name: (json['name'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      team: (json['team'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      hint: (json['hint'] ?? '').toString(),
      historyClues: (json['historyClues'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
    );
  }
}

