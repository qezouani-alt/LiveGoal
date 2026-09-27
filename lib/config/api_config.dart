class ApiConfig {
  // Replace this with your actual API-Football API key
  // Get it from: https://www.api-football.com/
  static const String apiKey = '57e11abc1d69a9c4c8c278e960e906c3';
  
  // Replace this with your actual Gemini API key
  // Get it from: https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'AIzaSyA764gmOI2pfKkDhw8UK7-8wPH6lRoCFOo';
  
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
  static bool get isConfigured => apiKey != '796efe5199fb5548866504df73ec3e9f' && apiKey.isNotEmpty;
  
  // Check if Gemini API is properly configured
  static bool get isGeminiConfigured => geminiApiKey != 'AIzaSyA764gmOI2pfKkDhw8UK7-8wPH6lRoCFOo' && geminiApiKey.isNotEmpty;
}
