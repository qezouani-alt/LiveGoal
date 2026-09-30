# Football Matches App ⚽

A Flutter application that displays football matches with a beautiful UI and API integration for real-time football data.

## Features 🚀

### UI Components
- **Top Bar**: Sport selector dropdown (Football, Basketball, Tennis) with search and settings
- **Date Selector**: Horizontal scrollable date picker with today highlighting
- **Promo Banner**: Dismissible feedback banner with NO/YES buttons
- **Main Menu**: All matches counter and competition sections
- **Bottom Navigation**: 5 tabs (All, Live, Favorites, News, Leagues)
- **Matches List**: Beautiful match cards with team logos, scores, and status

### API Integration
- **API-Football**: Full integration with the official football API
- **Real-time Data**: Live matches, fixtures, team information, and statistics
- **Demo Mode**: Sample data for testing without API key
- **Error Handling**: Comprehensive error handling and retry functionality

## API Setup 🔑

### 1. Get API Key
1. Visit [API-Football](https://www.api-football.com/)
2. Sign up for a free account
3. Get your API key from the dashboard

### 2. Configure API
1. Open `lib/config/api_config.dart`
2. Replace `YOUR_API_KEY_HERE` with your actual API key
3. Set `demoMode = false` to use real API data

```dart
class ApiConfig {
  static const String apiKey = 'YOUR_ACTUAL_API_KEY';
  static const bool demoMode = false; // Set to false for real data
}
```

### 3. API Endpoints Used
- **Fixtures**: Get matches by date, league, or live status
- **Teams**: Team information and logos
- **Leagues**: League details and standings
- **Countries**: Available countries and leagues
- **Events**: Match events and statistics

## Installation 📱

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- iOS Simulator or Android Emulator

### Setup
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure API key (see API Setup section)
4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure 📁

```
lib/
├── main.dart                 # Main app entry point
├── config/
│   └── api_config.dart      # API configuration
├── services/
│   └── api_football_service.dart  # API service layer
└── widgets/
    └── match_list_widget.dart     # Match list display
```

## Data Models 🏗️

### Match
- Basic match information (teams, time, venue)
- Score and status
- League details

### MatchDetails
- Extended match information
- Events timeline
- Lineups and statistics

### Team, League, Country
- Complete data models for all entities
- JSON serialization support

## Demo Mode 🎮

The app includes a demo mode that shows sample data:
- 4 sample matches with realistic data
- Team logos and league information
- Different match statuses (NS, LIVE, FT)
- Simulated API delay for realistic experience

## Customization 🎨

### Colors
- Primary: Red (#FF0000)
- Background: Light grey (#F5F5F5)
- Accents: Yellow for favorites, grey for sections

### Layout
- Responsive design for different screen sizes
- Material Design 3 principles
- Custom shadows and rounded corners

## API Rate Limits ⚠️

**Free Plan Limits:**
- 100 requests per day
- 1 request per second

**Paid Plans:**
- Higher limits available
- Real-time data access
- Additional endpoints

## Troubleshooting 🔧

### Common Issues
1. **API Key Error**: Ensure your API key is correctly set
2. **No Data**: Check internet connection and API status
3. **Rate Limit**: Wait or upgrade your API plan

### Debug Mode
- Set `demoMode = true` for offline testing
- Check console logs for API responses
- Use Flutter Inspector for UI debugging

## Contributing 🤝

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License 📄

This project is licensed under the MIT License.

## Support 💬

For API-related issues:
- [API-Football Documentation](https://www.api-football.com/documentation-v3)
- [API-Football Support](https://www.api-football.com/support)

For app issues:
- Create an issue in this repository
- Check Flutter documentation

---

**Built with ❤️ using Flutter and API-Football**
