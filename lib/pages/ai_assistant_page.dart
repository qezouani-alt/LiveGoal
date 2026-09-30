import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../main.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  
  // Track which quick prompts are visible
  final List<String> _visiblePrompts = [
    "Analyze Morocco vs Brazil",
    "Who's better: Messi or Ronaldo?",
    "Give me a football quiz",
  ];

  // Your Gemini API key
  static const String _geminiApiKey = "AIzaSyB_i76Jgxqn0NHgfu8TqYIbZx8oVS1jzxo";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // Add welcome message
    _messages.add(ChatMessage(
      text: "Hello! I'm Coach AI 🤖, your football expert assistant. Ask me anything about football!",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background (same as matches page)
          _buildElegantBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Chat messages
                Expanded(
                  child: _buildChatList(),
                ),
                
                // Quick prompts
                _buildQuickPrompts(),
                
                // Input area
                _buildInputArea(),
              ],
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

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF002366),
              size: 24,
            ),
          ),
          const Expanded(
            child: Text(
              "AI ASSISTANT",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF002366),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _clearChat,
            icon: const Icon(
              Icons.chat,
              color: Color(0xFF002366),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF002366), Color(0xFF004080)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.sports_soccer,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF002366), Color(0xFF004080)],
                      ),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isUser 
                      ? const Radius.circular(20) 
                      : const Radius.circular(4),
                  bottomRight: message.isUser 
                      ? const Radius.circular(4) 
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickPrompts() {
    // Only show if there are visible prompts
    if (_visiblePrompts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Prompts:",
            style: TextStyle(
              color: Color(0xFF002366),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _visiblePrompts.map((prompt) => _buildPromptButton(prompt)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptButton(String prompt) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF002366).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Prompt text (clickable to send)
          GestureDetector(
            onTap: () => _sendQuickPrompt(prompt),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                prompt,
                style: const TextStyle(
                  color: Color(0xFF002366),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // X button to remove
          GestureDetector(
            onTap: () => _removePrompt(prompt),
            child: Container(
              padding: const EdgeInsets.only(right: 8, left: 4, top: 8, bottom: 8),
              child: Icon(
                Icons.close,
                size: 16,
                color: const Color(0xFF002366).withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _removePrompt(String prompt) {
    setState(() {
      _visiblePrompts.remove(prompt);
    });
  }

  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Ask me anything about football...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isLoading ? null : _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: _isLoading
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF002366), Color(0xFF004080)],
                      ),
                color: _isLoading ? Colors.grey : null,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendQuickPrompt(String prompt) {
    _messageController.text = prompt;
    _sendMessage();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _getAIResponse(text);
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Error: ${e.toString()}. Please check your API key and try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  Future<String> _getAIResponse(String prompt) async {
    // Mock mode if no API key provided
    if (_geminiApiKey == "YOUR_API_KEY_HERE") {
      await Future.delayed(const Duration(seconds: 2));
      return _getMockResponse(prompt);
    }

    try {
      // Initialize the Generative AI model with basic configuration
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _geminiApiKey,
      );

      // Generate content
      final content = [Content.text(_buildSystemPrompt() + prompt)];
      final response = await model.generateContent(content);
      
      return response.text ?? "I couldn't generate a response. Please try again.";
    } catch (e) {
      // Log error for debugging in development
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        debugPrint('API Error: $e');
        debugPrint('API Key: ${_geminiApiKey.substring(0, 10)}...');
      }
      throw Exception('Failed to get AI response: $e');
    }
  }

  String _buildSystemPrompt() {
    return """You are "Coach AI" — a friendly football expert assistant. 
- Use Moroccan Arabic (Darija) when user writes in Darija, otherwise match user language.
- Answer accurately and briefly about football.
- Include small trivia or football facts sometimes.
- Keep replies safe and football-related only.
- Be helpful and enthusiastic about football.

User message: """;
  }

  String _getMockResponse(String prompt) {
    final responses = [
      "That's a great question! Let me analyze that for you...",
      "Interesting point! In football, there are many factors to consider...",
      "As a football expert, I'd say that depends on the context...",
      "Football is such an amazing sport! Here's what I think...",
      "Great question! Let me share some insights about that...",
    ];
    return responses[Random().nextInt(responses.length)];
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add(ChatMessage(
        text: "Hello! I'm Coach AI 🤖, your football expert assistant. Ask me anything about football!",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
