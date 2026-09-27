import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import '../main.dart' as main_app;

class FastChallengePage extends StatefulWidget {
  const FastChallengePage({super.key});

  @override
  State<FastChallengePage> createState() => _FastChallengePageState();
}

class _FastChallengePageState extends State<FastChallengePage>
    with TickerProviderStateMixin {
  List<FastQuestion> _questions = [];
  FastQuestion? _currentQuestion;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = 30; // 30 seconds
  bool _gameStarted = false;
  bool _gameEnded = false;
  Timer? _timer;
  late AnimationController _timerController;
  late AnimationController _questionController;
  late Animation<double> _timerAnimation;
  late Animation<double> _questionAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadQuestions();
  }

  void _initializeAnimations() {
    _timerController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _questionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.linear),
    );
    _questionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/fast_challenge_questions.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _questions = jsonList.map((json) => FastQuestion.fromJson(json)).toList();
        _shuffleQuestions(); // Enhanced randomization
      });
    } catch (e) {
      // Fallback data if file doesn't exist
      setState(() {
        _questions = _getFallbackQuestions();
        _shuffleQuestions();
      });
    }
  }

  void _shuffleQuestions() {
    // Use current time as seed for better randomization
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    _questions.shuffle(random);
    
    // Also shuffle options within each question for extra variety
    for (var question in _questions) {
      question.options.shuffle(random);
    }
  }

  void _startGame() {
    // Reshuffle questions for each new game
    _shuffleQuestions();
    
    setState(() {
      _gameStarted = true;
      _gameEnded = false;
      _score = 0;
      _timeLeft = 30;
      _currentQuestionIndex = 0;
    });
    
    _loadNextQuestion();
    _startTimer();
  }

  void _startTimer() {
    _timerController.reset();
    _timerController.forward();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
      });
      
      if (_timeLeft <= 0) {
        _endGame();
      }
    });
  }

  void _loadNextQuestion() {
    if (_currentQuestionIndex < _questions.length) {
      setState(() {
        _currentQuestion = _questions[_currentQuestionIndex];
      });
      _questionController.forward();
    } else {
      // No more questions, end game
      _endGame();
    }
  }

  void _selectAnswer(String selectedAnswer) {
    if (_currentQuestion == null || _gameEnded) return;
    
    bool isCorrect = selectedAnswer == _currentQuestion!.correctAnswer;
    
    if (isCorrect) {
      setState(() {
        _score++;
      });
    }
    
    _nextQuestion();
  }

  void _nextQuestion() {
    _questionController.reverse().then((_) {
      setState(() {
        _currentQuestionIndex++;
      });
      _loadNextQuestion();
    });
  }

  void _endGame() {
    _timer?.cancel();
    _timerController.stop();
    setState(() {
      _gameEnded = true;
    });
  }

  void _playAgain() {
    // Reshuffle questions for each new game
    _shuffleQuestions();
    
    setState(() {
      _gameStarted = false;
      _gameEnded = false;
      _score = 0;
      _timeLeft = 30;
      _currentQuestionIndex = 0;
      _currentQuestion = null;
    });
    _timerController.reset();
    _questionController.reset();
  }

  List<FastQuestion> _getFallbackQuestions() {
    return [
      FastQuestion(
        question: "Which country won the 2018 World Cup?",
        options: ["France", "Croatia", "Brazil", "Germany"],
        correctAnswer: "France",
        category: "World Cup",
      ),
      FastQuestion(
        question: "Who is known as 'The Special One'?",
        options: ["Pep Guardiola", "Jose Mourinho", "Jurgen Klopp", "Carlo Ancelotti"],
        correctAnswer: "Jose Mourinho",
        category: "Managers",
      ),
      FastQuestion(
        question: "Which club is known as 'The Red Devils'?",
        options: ["Liverpool", "Manchester United", "Arsenal", "Chelsea"],
        correctAnswer: "Manchester United",
        category: "Clubs",
      ),
      FastQuestion(
        question: "How many players are on a football team?",
        options: ["10", "11", "12", "9"],
        correctAnswer: "11",
        category: "Rules",
      ),
      FastQuestion(
        question: "Which player has won the most Ballon d'Or awards?",
        options: ["Cristiano Ronaldo", "Lionel Messi", "Pele", "Maradona"],
        correctAnswer: "Lionel Messi",
        category: "Players",
      ),
      FastQuestion(
        question: "What is the duration of a football match?",
        options: ["80 minutes", "90 minutes", "100 minutes", "120 minutes"],
        correctAnswer: "90 minutes",
        category: "Rules",
      ),
      FastQuestion(
        question: "Which country has won the most World Cups?",
        options: ["Germany", "Brazil", "Argentina", "Italy"],
        correctAnswer: "Brazil",
        category: "World Cup",
      ),
      FastQuestion(
        question: "What is the name of Real Madrid's stadium?",
        options: ["Camp Nou", "Santiago Bernabeu", "Wembley", "San Siro"],
        correctAnswer: "Santiago Bernabeu",
        category: "Stadiums",
      ),
      FastQuestion(
        question: "Which league is known as 'La Liga'?",
        options: ["English Premier League", "Spanish League", "Italian League", "German League"],
        correctAnswer: "Spanish League",
        category: "Leagues",
      ),
      FastQuestion(
        question: "Who scored the 'Hand of God' goal?",
        options: ["Pele", "Maradona", "Ronaldinho", "Zidane"],
        correctAnswer: "Maradona",
        category: "Players",
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
          'Fast Challenge',
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
                          if (!_gameStarted && !_gameEnded) _buildStartScreen(),
                          if (_gameStarted && !_gameEnded) ...[
                            _buildTimer(),
                            const SizedBox(height: 20),
                            _buildScore(),
                            const SizedBox(height: 20),
                            _buildQuestion(),
                          ],
                          if (_gameEnded) _buildEndScreen(),
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

  Widget _buildStartScreen() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
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
          Icon(
            Icons.timer,
            size: 64,
            color: const Color(0xFF002366),
          ),
          const SizedBox(height: 16),
          const Text(
            'Fast Challenge',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002366),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '30 seconds of rapid-fire football questions!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Start Challenge',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _timerAnimation,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: _timerAnimation.value,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _timeLeft > 10 ? Colors.green : (_timeLeft > 5 ? Colors.orange : Colors.red),
                      ),
                    );
                  },
                ),
                Center(
                  child: Text(
                    '$_timeLeft',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002366),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Time Remaining',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScore() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF002366).withValues(alpha: 0.4), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: Colors.amber,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Score: $_score',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002366),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    if (_currentQuestion == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF002366).withValues(alpha: 0.4), width: 2),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF002366),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _questionAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _questionAnimation.value,
          child: Opacity(
            opacity: _questionAnimation.value,
            child: Container(
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF002366).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currentQuestion!.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF002366),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentQuestion!.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._currentQuestion!.options.map((option) => 
                    _buildOptionButton(option)
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(String option) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () => _selectAnswer(option),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF002366),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF002366), width: 2),
          ),
        ),
        child: Text(
          option,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEndScreen() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
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
          Icon(
            Icons.emoji_events,
            size: 64,
            color: _score >= 8 ? Colors.amber : (_score >= 5 ? Colors.orange : Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            'Time\'s Up!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002366),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Score: $_score',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002366),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getScoreMessage(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _playAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getScoreMessage() {
    if (_score >= 8) return 'Excellent! You\'re a football expert! 🏆';
    if (_score >= 5) return 'Good job! You know your football! ⚽';
    if (_score >= 3) return 'Not bad! Keep practicing! 💪';
    return 'Better luck next time! Keep learning! 📚';
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

class FastQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String category;

  FastQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.category,
  });

  factory FastQuestion.fromJson(Map<String, dynamic> json) {
    return FastQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
