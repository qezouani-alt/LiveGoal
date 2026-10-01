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

Copy `config.example.json` to `config.local.json` and fill in the API keys you use:

- `API_FOOTBALL_KEY`: fixtures and scores
- `GEMINI_API_KEY`: AI service
- `GEMINI_ASSISTANT_API_KEY`: Coach AI page
- `NEWS_API_KEY`: news articles

`config.local.json` is ignored by Git. Keep it on your machine and run with:

```bash
flutter run --dart-define-from-file=config.local.json
```

In VS Code, select the **LiveGoal AI (local keys)** launch configuration. A
configuration is provided for opening either this `foot` directory or its
parent workspace.

These keys are still embedded in the built mobile app. For a public release,
put paid or sensitive API calls behind a server you control and rotate any keys
that were previously committed or shared.

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
3. Create `config.local.json` (see API Setup section)
4. Run the app:
   ```bash
   flutter run --dart-define-from-file=config.local.json
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
