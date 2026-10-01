class ApiConfig {
  // Supply these at launch with --dart-define-from-file=config.local.json.
  static const String apiKey = String.fromEnvironment('API_FOOTBALL_KEY');

  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String assistantGeminiApiKey = String.fromEnvironment(
    'GEMINI_ASSISTANT_API_KEY',
  );

  // Demo mode - when true, shows sample data instead of making API calls
  static const bool demoMode = false;
  
  // API endpoints
  static const String baseUrl = 'https://v3.football.api-sports.io';
  
  // Headers required by API-Football
  static Map<String, String> get headers => {
    'x-rapidapi-host': 'v3.football.api-sports.io',
    'x-rapidapi-key': apiKey,
  };
  
  // Check if API is properly configured
  static bool get isConfigured => apiKey.isNotEmpty;
  
  // Check if Gemini API is properly configured
  static bool get isGeminiConfigured => geminiApiKey.isNotEmpty;

  static bool get isAssistantGeminiConfigured =>
      assistantGeminiApiKey.isNotEmpty;
}
