import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../main.dart' as main_app;

class GuessTheYearPage extends StatefulWidget {
  const GuessTheYearPage({super.key});

  @override
  State<GuessTheYearPage> createState() => _GuessTheYearPageState();
}

class _GuessTheYearPageState extends State<GuessTheYearPage> {
  List<YearEvent> _events = [];
  YearEvent? _currentEvent;
  int _currentEventIndex = 0;
  final TextEditingController _yearController = TextEditingController();
  bool _answerChecked = false;
  bool _isCorrect = false;
  int _wrongAttempts = 0;
  bool _canCheck = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _yearController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_answerChecked) {
      setState(() {
        _canCheck = _yearController.text.trim().isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/year_events.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _events = jsonList.map((json) => YearEvent.fromJson(json)).toList();
        _loadRandomEvent();
      });
    } catch (e) {
      // Fallback data if file doesn't exist
      setState(() {
        _events = _getFallbackEvents();
        _loadRandomEvent();
      });
    }
  }

  void _loadRandomEvent() {
    if (_events.isNotEmpty) {
      setState(() {
        _currentEventIndex = (DateTime.now().millisecondsSinceEpoch % _events.length);
        _currentEvent = _events[_currentEventIndex];
        _yearController.clear();
        _answerChecked = false;
        _isCorrect = false;
        _wrongAttempts = 0;
        _canCheck = false;
      });
    }
  }

  void _checkAnswer() {
    if (_currentEvent == null || _yearController.text.trim().isEmpty) return;
    
    final userYear = int.tryParse(_yearController.text.trim());
    if (userYear == null) return;
    
    setState(() {
      _answerChecked = true;
      _isCorrect = userYear == _currentEvent!.year;
      if (!_isCorrect) {
        _wrongAttempts++;
      }
    });
  }

  void _retry() {
    setState(() {
      _yearController.clear();
      _answerChecked = false;
      _canCheck = false;
    });
  }

  List<YearEvent> _getFallbackEvents() {
    return [
      YearEvent(
        event: "France won the World Cup",
        year: 2018,
        hint: "Held in Russia",
        description: "France defeated Croatia 4-2 in the final",
      ),
      YearEvent(
        event: "Brazil won the World Cup",
        year: 2002,
        hint: "Held in Japan and South Korea",
        description: "Brazil defeated Germany 2-0 in the final",
      ),
      YearEvent(
        event: "Spain won the World Cup",
        year: 2010,
        hint: "Held in South Africa",
        description: "Spain defeated Netherlands 1-0 in the final",
      ),
      YearEvent(
        event: "Germany won the World Cup",
        year: 2014,
        hint: "Held in Brazil",
        description: "Germany defeated Argentina 1-0 in the final",
      ),
      YearEvent(
        event: "Italy won the World Cup",
        year: 2006,
        hint: "Held in Germany",
        description: "Italy defeated France 5-3 on penalties",
      ),
      YearEvent(
        event: "Real Madrid won their 10th Champions League",
        year: 2014,
        hint: "La Decima",
        description: "Real Madrid defeated Atletico Madrid 4-1 in the final",
      ),
      YearEvent(
        event: "Barcelona won the treble",
        year: 2009,
        hint: "Under Pep Guardiola",
        description: "Won La Liga, Copa del Rey, and Champions League",
      ),
      YearEvent(
        event: "Leicester City won the Premier League",
        year: 2016,
        hint: "5000-1 odds at the start of the season",
        description: "Claudio Ranieri's miracle season",
      ),
      YearEvent(
        event: "Manchester United won the treble",
        year: 1999,
        hint: "Under Sir Alex Ferguson",
        description: "Won Premier League, FA Cup, and Champions League",
      ),
      YearEvent(
        event: "AC Milan won the Champions League",
        year: 2007,
        hint: "Revenge for Istanbul",
        description: "AC Milan defeated Liverpool 2-1 in the final",
      ),
    ];
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
        title: const Text(
          'Guess the Year',
          style: TextStyle(
            color: Color(0xFF002366),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildElegantBackground(),
          LayoutBuilder(
            builder: (context, constraints) {
              final topSafeSpace = MediaQuery.of(context).padding.top + kToolbarHeight;
              final minHeight = constraints.maxHeight - topSafeSpace;
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Padding(
                    padding: EdgeInsets.only(top: topSafeSpace),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildEventCard(),
                          const SizedBox(height: 20),
                          _buildYearInput(),
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

  Widget _buildEventCard() {
    if (_currentEvent == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
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
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF002366),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
              Icon(
                Icons.sports_soccer,
                color: const Color(0xFF002366),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Football Event',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002366),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentEvent!.event,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (_currentEvent!.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _currentEvent!.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildYearInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
          const Text(
            'What year did this happen?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002366),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _yearController,
            keyboardType: TextInputType.number,
            readOnly: _answerChecked,
            decoration: InputDecoration(
              hintText: 'Enter the year (e.g., 2018)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF002366)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF002366), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: _answerChecked,
              fillColor: _answerChecked ? Colors.grey.withValues(alpha: 0.1) : null,
            ),
            style: TextStyle(
              fontSize: 16,
              color: _answerChecked ? Colors.grey[600] : Colors.black,
            ),
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
              onPressed: _canCheck ? _checkAnswer : null,
              icon: const Icon(Icons.check, size: 20),
              label: const Text('Check'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _canCheck ? const Color(0xFF002366) : Colors.grey,
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
                onPressed: _loadRandomEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Next Question'),
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
                        onPressed: _loadRandomEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4D00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Skip this event'),
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

  void _showHintDialog() {
    if (_currentEvent == null) return;
    
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
            Text('Hint: ${_currentEvent!.hint}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
    if (_currentEvent == null) return;
    
    final yearString = _currentEvent!.year.toString();
    final firstChar = yearString.isNotEmpty ? yearString[0] : '';
    final lastChar = yearString.length > 1 ? yearString[yearString.length - 1] : '';
    
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
              'Here are the first and last digits:',
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

class YearEvent {
  final String event;
  final int year;
  final String hint;
  final String description;

  YearEvent({
    required this.event,
    required this.year,
    required this.hint,
    required this.description,
  });

  factory YearEvent.fromJson(Map<String, dynamic> json) {
    return YearEvent(
      event: json['event'] ?? '',
      year: json['year'] ?? 0,
      hint: json['hint'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
