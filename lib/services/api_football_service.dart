import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiFootballService {
  static const String _baseUrl = ApiConfig.baseUrl;
  
  // Headers required by API-Football
  static Map<String, String> get _headers => ApiConfig.headers;

  /// Get today's matches across all leagues
  static Future<List<Match>> getTodayMatches() async {
    try {
      final today = DateTime.now();
      final date = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final response = await http.get(
        Uri.parse('$_baseUrl/fixtures?date=$date'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null) {
          return (data['response'] as List)
              .map((match) => Match.fromJson(match))
              .toList();
        }
      }
      
      throw Exception('Failed to load today\'s matches');
    } catch (e) {
      throw Exception('Error fetching today\'s matches: $e');
    }
  }

  /// Get matches for a specific date
  static Future<List<Match>> getMatchesByDate(String date) async {
    // Demo mode - return sample data
    if (ApiConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate API delay
      return _getDemoMatches(date);
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/fixtures?date=$date'),
        headers: _headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null) {
          return (data['response'] as List)
              .map((match) => Match.fromJson(match))
              .toList();
        }
      }
      
      throw Exception('Failed to load matches for $date');
    } catch (e) {
      throw Exception('Error fetching matches for $date: $e');
    }
  }

  /// Get match details by fixture ID
  static Future<MatchDetails> getMatchDetails(int fixtureId) async {
    // Demo mode - return sample data
    if (ApiConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate API delay
      return _getDemoMatchDetails(fixtureId);
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/fixtures?id=$fixtureId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null && data['response'].isNotEmpty) {
          return MatchDetails.fromJson(data['response'][0]);
        }
      }
      
      throw Exception('Failed to load match details');
    } catch (e) {
      throw Exception('Error fetching match details: $e');
    }
  }

  /// Get head-to-head matches between two teams
  static Future<List<Match>> getHeadToHead(int team1Id, int team2Id) async {
    // Demo mode - return sample data
    if (ApiConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _getDemoHeadToHead(team1Id, team2Id);
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/fixtures?h2h=$team1Id-$team2Id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null) {
          return (data['response'] as List)
              .map((match) => Match.fromJson(match))
              .toList();
        }
      }
      
      throw Exception('Failed to load head-to-head matches');
    } catch (e) {
      throw Exception('Error fetching head-to-head matches: $e');
    }
  }

  /// Get team's recent form/matches
  static Future<List<Match>> getTeamRecentMatches(int teamId) async {
    // Demo mode - return sample data
    if (ApiConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _getDemoTeamRecentMatches(teamId);
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/fixtures?team=$teamId&last=10'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null) {
          return (data['response'] as List)
              .map((match) => Match.fromJson(match))
              .toList();
        }
      }
      
      throw Exception('Failed to load team recent matches');
    } catch (e) {
      throw Exception('Error fetching team recent matches: $e');
    }
  }

  /// Get league standings
  static Future<List<Standing>> getLeagueStandings(int leagueId, int season) async {
    // Demo mode - return sample data
    if (ApiConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _getDemoStandings(leagueId, season);
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/standings?league=$leagueId&season=$season'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null && data['response'].isNotEmpty) {
          return (data['response'][0]['league']['standings'][0] as List)
              .map((standing) => Standing.fromJson(standing))
              .toList();
        }
      }
      
      throw Exception('Failed to load league standings');
    } catch (e) {
      throw Exception('Error fetching league standings: $e');
    }
  }

  /// Get live matches
  static Future<List<Match>> getLiveMatches() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/fixtures?live=all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null) {
          return (data['response'] as List)
              .map((match) => Match.fromJson(match))
              .toList();
        }
      }
      
      throw Exception('Failed to load live matches');
    } catch (e) {
      throw Exception('Error fetching live matches: $e');
    }
  }

  /// Get matches by league
  static Future<List<Match>> getMatchesByLeague(int leagueId, {int? season}) async {
    try {
      String url = '$_baseUrl/fixtures?league=$leagueId';
      if (season != null) {
        url += '&season=$season';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null) {
          return (data['response'] as List)
              .map((match) => Match.fromJson(match))
              .toList();
        }
      }
      
      throw Exception('Failed to load league matches');
    } catch (e) {
      throw Exception('Error fetching league matches: $e');
    }
  }

  /// Get leagues by country
  static Future<List<League>> getLeaguesByCountry(String country) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/leagues?country=$country'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null) {
          List<League> leagues = [];
          
          for (var item in data['response']) {
            try {
              // The API response structure is: { "league": {...}, "country": {...}, "seasons": [...] }
              if (item['league'] != null) {
                leagues.add(League.fromJson(item['league']));
              }
            } catch (e) {
              // Skip invalid entries
              // Skip invalid entries
              continue;
            }
          }
          
          return leagues;
        }
      }
      
      throw Exception('Failed to load leagues for $country');
    } catch (e) {
      throw Exception('Error fetching leagues for $country: $e');
    }
  }

  /// Get all available countries
  static Future<List<Country>> getCountries() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/countries'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null) {
          return (data['response'] as List)
              .map((country) => Country.fromJson(country))
              .toList();
        }
      }
      
      throw Exception('Failed to load countries');
    } catch (e) {
      throw Exception('Error fetching countries: $e');
    }
  }

  /// Get all major leagues/competitions worldwide
  static Future<List<League>> getAllLeagues() async {
    // Demo mode - return sample data
    if (ApiConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate API delay
      return _getDemoLeagues();
    }
    
    try {
      // Get leagues from major countries
      List<String> majorCountries = ['England', 'Spain', 'Germany', 'Italy', 'France', 'Netherlands', 'Portugal', 'Brazil', 'Argentina'];
      List<League> allLeagues = [];
      
      for (String country in majorCountries) {
        try {
          final countryLeagues = await getLeaguesByCountry(country);
          allLeagues.addAll(countryLeagues);
        } catch (e) {
          // Skip countries that fail
          // Skip countries that fail
          continue;
        }
      }
      
      // Sort A to Z by league name
      allLeagues.sort((a, b) => a.name.compareTo(b.name));
      
      return allLeagues;
    } catch (e) {
      throw Exception('Error fetching leagues: $e');
    }
  }

  /// Get matches for a league on the current date (today)
  static Future<List<Match>> getCompetitionMatchesToday(int leagueId) async {
    final today = DateTime.now();
    final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/fixtures?league=$leagueId&date=$dateString'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null) {
          return (data['response'] as List)
              .map((match) => Match.fromJson(match))
              .toList();
        }
      }
      throw Exception('Failed to load matches');
    } catch (e) {
      // Fallback: filter matches by league from today's matches in demo mode.
      final allToday = await getMatchesByDate(dateString);
      return allToday.where((m) => m.league.id == leagueId).toList();
    }
  }

  /// Demo mode - returns sample match data
  static List<Match> _getDemoMatches(String date) {
    return [
      Match(
        id: 1,
        date: date,
        time: '20:00',
        status: 'NS',
        homeTeam: Team(
          id: 1,
          name: 'Manchester United',
          logo: 'https://media.api-sports.io/football/teams/33.png',
        ),
        awayTeam: Team(
          id: 2,
          name: 'Liverpool',
          logo: 'https://media.api-sports.io/football/teams/40.png',
        ),
        league: League(
          id: 39,
          name: 'Premier League',
          country: 'England',
          logo: 'https://media.api-sports.io/football/leagues/39.png',
          flag: 'https://media.api-sports.io/flags/gb.svg',
          season: 2024,
          round: 'Regular Season - 1',
        ),
        venue: 'Old Trafford',
      ),
      Match(
        id: 2,
        date: date,
        time: '21:30',
        status: 'NS',
        homeTeam: Team(
          id: 3,
          name: 'Real Madrid',
          logo: 'https://media.api-sports.io/football/teams/541.png',
        ),
        awayTeam: Team(
          id: 4,
          name: 'Barcelona',
          logo: 'https://media.api-sports.io/football/teams/529.png',
        ),
        league: League(
          id: 140,
          name: 'La Liga',
          country: 'Spain',
          logo: 'https://media.api-sports.io/football/leagues/140.png',
          flag: 'https://media.api-sports.io/flags/es.svg',
          season: 2024,
          round: 'Regular Season - 1',
        ),
        venue: 'Santiago Bernabéu',
      ),
      Match(
        id: 3,
        date: date,
        time: '19:45',
        status: 'NS',
        homeTeam: Team(
          id: 5,
          name: 'Bayern Munich',
          logo: 'https://media.api-sports.io/football/teams/157.png',
        ),
        awayTeam: Team(
          id: 6,
          name: 'Borussia Dortmund',
          logo: 'https://media.api-sports.io/football/teams/165.png',
        ),
        league: League(
          id: 78,
          name: 'Bundesliga',
          country: 'Germany',
          logo: 'https://media.api-sports.io/football/leagues/78.png',
          flag: 'https://media.api-sports.io/flags/gb.svg',
          season: 2024,
          round: 'Regular Season - 1',
        ),
        venue: 'Allianz Arena',
      ),
      Match(
        id: 4,
        date: date,
        time: '20:00',
        status: 'LIVE',
        homeTeam: Team(
          id: 7,
          name: 'PSG',
          logo: 'https://media.api-sports.io/football/teams/85.png',
        ),
        awayTeam: Team(
          id: 8,
          name: 'Marseille',
          logo: 'https://media.api-sports.io/football/teams/81.png',
        ),
        score: Score(home: 2, away: 1),
        league: League(
          id: 61,
          name: 'Ligue 1',
          country: 'France',
          logo: 'https://media.api-sports.io/football/leagues/61.png',
          flag: 'https://media.api-sports.io/flags/fr.svg',
          season: 2024,
          round: 'Regular Season - 1',
        ),
        venue: 'Parc des Princes',
      ),
    ];
  }

  /// Demo mode - returns sample leagues data
  static List<League> _getDemoLeagues() {
    return [
      League(id: 39, name: 'Premier League', country: 'England', logo: 'https://media.api-sports.io/football/leagues/39.png', flag: 'https://media.api-sports.io/flags/gb.svg', season: 2024, round: 'Regular Season'),
      League(id: 140, name: 'La Liga', country: 'Spain', logo: 'https://media.api-sports.io/football/leagues/140.png', flag: 'https://media.api-sports.io/flags/es.svg', season: 2024, round: 'Regular Season'),
      League(id: 78, name: 'Bundesliga', country: 'Germany', logo: 'https://media.api-sports.io/football/leagues/78.png', flag: 'https://media.api-sports.io/flags/de.svg', season: 2024, round: 'Regular Season'),
      League(id: 61, name: 'Ligue 1', country: 'France', logo: 'https://media.api-sports.io/football/leagues/61.png', flag: 'https://media.api-sports.io/flags/fr.svg', season: 2024, round: 'Regular Season'),
      League(id: 135, name: 'Serie A', country: 'Italy', logo: 'https://media.api-sports.io/football/leagues/135.png', flag: 'https://media.api-sports.io/flags/it.svg', season: 2024, round: 'Regular Season'),
      League(id: 88, name: 'Eredivisie', country: 'Netherlands', logo: 'https://media.api-sports.io/football/leagues/88.png', flag: 'https://media.api-sports.io/flags/nl.svg', season: 2024, round: 'Regular Season'),
      League(id: 94, name: 'Primeira Liga', country: 'Portugal', logo: 'https://media.api-sports.io/football/leagues/94.png', flag: 'https://media.api-sports.io/flags/pt.svg', season: 2024, round: 'Regular Season'),
      League(id: 144, name: 'Pro League', country: 'Belgium', logo: 'https://media.api-sports.io/football/leagues/144.png', flag: 'https://media.api-sports.io/flags/be.svg', season: 2024, round: 'Regular Season'),
    ]..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Demo mode - returns sample match details data
  static MatchDetails _getDemoMatchDetails(int fixtureId) {
    return MatchDetails(
      id: fixtureId,
      date: '2024-01-15',
      time: '20:00',
      status: 'LIVE',
      homeTeam: Team(
        id: 1,
        name: 'Manchester United',
        logo: 'https://media.api-sports.io/football/teams/33.png',
      ),
      awayTeam: Team(
        id: 2,
        name: 'Liverpool',
        logo: 'https://media.api-sports.io/football/teams/40.png',
      ),
      score: Score(home: 2, away: 1),
      league: League(
        id: 39,
        name: 'Premier League',
        country: 'England',
        logo: 'https://media.api-sports.io/football/leagues/39.png',
        flag: 'https://media.api-sports.io/flags/gb.svg',
        season: 2024,
        round: 'Regular Season - 20',
      ),
      venue: 'Old Trafford',
      events: [
        Event(
          time: 15,
          type: 'Goal',
          detail: 'Normal Goal',
          team: Team(id: 1, name: 'Manchester United', logo: ''),
          player: Player(id: 2, name: 'Marcus Rashford', number: 10, position: 'FW', grid: '3-2'),
          assist: Player(id: 3, name: 'Bruno Fernandes', number: 18, position: 'MF', grid: '2-2'),
          eventType: 'Normal Goal',
          comments: 'Assisted by Bruno Fernandes',
        ),
        Event(
          time: 23,
          type: 'Card',
          detail: 'Yellow Card',
          team: Team(id: 2, name: 'Liverpool', logo: ''),
          player: Player(id: 7, name: 'Virgil van Dijk', number: 4, position: 'DF', grid: '2-2'),
          eventType: 'Yellow Card',
          comments: 'Foul on Marcus Rashford',
        ),
        Event(
          time: 45,
          type: 'Goal',
          detail: 'Penalty',
          team: Team(id: 2, name: 'Liverpool', logo: ''),
          player: Player(id: 8, name: 'Mohamed Salah', number: 11, position: 'FW', grid: '3-2'),
          eventType: 'Penalty',
          comments: 'Penalty won by Darwin Núñez',
        ),
        Event(
          time: 67,
          type: 'Goal',
          detail: 'Normal Goal',
          team: Team(id: 1, name: 'Manchester United', logo: ''),
          player: Player(id: 3, name: 'Bruno Fernandes', number: 18, position: 'MF', grid: '2-2'),
          eventType: 'Normal Goal',
          comments: 'Free kick goal',
        ),
        Event(
          time: 70,
          type: 'Subst',
          detail: 'Substitution 1',
          team: Team(id: 1, name: 'Manchester United', logo: ''),
          player: Player(id: 4, name: 'Jadon Sancho', number: 25, position: 'FW', grid: '3-3'),
          playerOut: Player(id: 2, name: 'Marcus Rashford', number: 10, position: 'FW', grid: '3-2'),
          playerIn: Player(id: 4, name: 'Jadon Sancho', number: 25, position: 'FW', grid: '3-3'),
          eventType: 'Substitution',
          comments: 'Jadon Sancho replaces Marcus Rashford',
        ),
        Event(
          time: 75,
          type: 'Card',
          detail: 'Red Card',
          team: Team(id: 2, name: 'Liverpool', logo: ''),
          player: Player(id: 9, name: 'Darwin Núñez', number: 27, position: 'FW', grid: '3-3'),
          eventType: 'Red Card',
          comments: 'Second yellow card',
        ),
        Event(
          time: 80,
          type: 'Subst',
          detail: 'Substitution 2',
          team: Team(id: 2, name: 'Liverpool', logo: ''),
          player: Player(id: 10, name: 'Cody Gakpo', number: 18, position: 'FW', grid: '3-3'),
          playerOut: Player(id: 8, name: 'Mohamed Salah', number: 11, position: 'FW', grid: '3-2'),
          playerIn: Player(id: 10, name: 'Cody Gakpo', number: 18, position: 'FW', grid: '3-3'),
          eventType: 'Substitution',
          comments: 'Cody Gakpo replaces Mohamed Salah',
        ),
        Event(
          time: 85,
          type: 'Subst',
          detail: 'Substitution 3',
          team: Team(id: 1, name: 'Manchester United', logo: ''),
          player: Player(id: 11, name: 'Anthony Martial', number: 9, position: 'FW', grid: '3-1'),
          playerOut: Player(id: 3, name: 'Bruno Fernandes', number: 18, position: 'MF', grid: '2-2'),
          playerIn: Player(id: 11, name: 'Anthony Martial', number: 9, position: 'FW', grid: '3-1'),
          eventType: 'Substitution',
          comments: 'Anthony Martial replaces Bruno Fernandes',
        ),
      ],
      lineups: [
        Lineup(
          team: Team(id: 1, name: 'Manchester United', logo: ''),
          starting: [
            Player(id: 1, name: 'David de Gea', number: 1, position: 'GK', grid: '1-1'),
            Player(id: 2, name: 'Marcus Rashford', number: 10, position: 'FW', grid: '3-2'),
            Player(id: 3, name: 'Bruno Fernandes', number: 18, position: 'MF', grid: '2-2'),
          ],
          substitutes: [
            Player(id: 4, name: 'Jadon Sancho', number: 25, position: 'FW', grid: '3-3'),
          ],
          coach: [
            Player(id: 5, name: 'Erik ten Hag', number: 1, position: 'Coach', grid: '0-0'),
          ],
        ),
        Lineup(
          team: Team(id: 2, name: 'Liverpool', logo: ''),
          starting: [
            Player(id: 6, name: 'Alisson', number: 1, position: 'GK', grid: '1-1'),
            Player(id: 7, name: 'Virgil van Dijk', number: 4, position: 'DF', grid: '2-2'),
            Player(id: 8, name: 'Mohamed Salah', number: 11, position: 'FW', grid: '3-2'),
          ],
          substitutes: [
            Player(id: 9, name: 'Darwin Núñez', number: 27, position: 'FW', grid: '3-3'),
          ],
          coach: [
            Player(id: 10, name: 'Jürgen Klopp', number: 1, position: 'Coach', grid: '0-0'),
          ],
        ),
      ],
      statistics: Statistics(
        home: {
          'Possession': '55%',
          'Shots': '12',
          'Shots on Target': '6',
          'Corners': '8',
          'Fouls': '9',
        },
        away: {
          'Possession': '45%',
          'Shots': '10',
          'Shots on Target': '4',
          'Corners': '5',
          'Fouls': '11',
        },
      ),
    );
  }

  /// Demo mode - returns sample head-to-head matches
  static List<Match> _getDemoHeadToHead(int team1Id, int team2Id) {
    return [
      Match(
        id: 101,
        date: '2023-12-20',
        time: '20:00',
        status: 'FT',
        homeTeam: Team(id: team1Id, name: 'Team A', logo: ''),
        awayTeam: Team(id: team2Id, name: 'Team B', logo: ''),
        score: Score(home: 2, away: 0),
        league: League(
          id: 39,
          name: 'Premier League',
          country: 'England',
          logo: 'https://media.api-sports.io/football/leagues/39.png',
          flag: 'https://media.api-sports.io/flags/gb.svg',
          season: 2023,
          round: 'Regular Season - 18',
        ),
        venue: 'Stadium A',
      ),
      Match(
        id: 102,
        date: '2023-08-15',
        time: '15:00',
        status: 'FT',
        homeTeam: Team(id: team2Id, name: 'Team B', logo: ''),
        awayTeam: Team(id: team1Id, name: 'Team A', logo: ''),
        score: Score(home: 1, away: 1),
        league: League(
          id: 39,
          name: 'Premier League',
          country: 'England',
          logo: 'https://media.api-sports.io/football/leagues/39.png',
          flag: 'https://media.api-sports.io/flags/gb.svg',
          season: 2023,
          round: 'Regular Season - 1',
        ),
        venue: 'Stadium B',
      ),
    ];
  }

  /// Demo mode - returns sample team recent matches
  static List<Match> _getDemoTeamRecentMatches(int teamId) {
    return [
      Match(
        id: 201,
        date: '2024-01-10',
        time: '20:00',
        status: 'FT',
        homeTeam: Team(id: teamId, name: 'Team A', logo: ''),
        awayTeam: Team(id: 999, name: 'Opponent 1', logo: ''),
        score: Score(home: 3, away: 1),
        league: League(
          id: 39,
          name: 'Premier League',
          country: 'England',
          logo: 'https://media.api-sports.io/football/leagues/39.png',
          flag: 'https://media.api-sports.io/flags/gb.svg',
          season: 2024,
          round: 'Regular Season - 19',
        ),
        venue: 'Home Stadium',
      ),
      Match(
        id: 202,
        date: '2024-01-05',
        time: '15:00',
        status: 'FT',
        homeTeam: Team(id: 998, name: 'Opponent 2', logo: ''),
        awayTeam: Team(id: teamId, name: 'Team A', logo: ''),
        score: Score(home: 0, away: 2),
        league: League(
          id: 39,
          name: 'Premier League',
          country: 'England',
          logo: 'https://media.api-sports.io/football/leagues/39.png',
          flag: 'https://media.api-sports.io/flags/gb.svg',
          season: 2024,
          round: 'Regular Season - 18',
        ),
        venue: 'Away Stadium',
      ),
    ];
  }

  /// Demo mode - returns sample league standings
  static List<Standing> _getDemoStandings(int leagueId, int season) {
    return [
      Standing(
        rank: 1,
        team: Team(id: 1, name: 'Arsenal', logo: ''),
        points: 45,
        goalsDiff: 25,
        played: 20,
        win: 14,
        draw: 3,
        lose: 3,
        goalsFor: 42,
        goalsAgainst: 17,
      ),
      Standing(
        rank: 2,
        team: Team(id: 2, name: 'Manchester City', logo: ''),
        points: 43,
        goalsDiff: 20,
        played: 20,
        win: 13,
        draw: 4,
        lose: 3,
        goalsFor: 48,
        goalsAgainst: 28,
      ),
      Standing(
        rank: 3,
        team: Team(id: 3, name: 'Newcastle', logo: ''),
        points: 40,
        goalsDiff: 15,
        played: 20,
        win: 12,
        draw: 4,
        lose: 4,
        goalsFor: 35,
        goalsAgainst: 20,
      ),
    ];
  }
}

// Data Models
class Match {
  final int id;
  final String date;
  final String time;
  final String status;
  final Team homeTeam;
  final Team awayTeam;
  final Score? score;
  final League league;
  final String venue;

  Match({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
    required this.homeTeam,
    required this.awayTeam,
    this.score,
    required this.league,
    required this.venue,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    final fixtureDate = json['fixture']['date'];
    String date = 'TBD';
    String time = 'TBD';
    
    if (fixtureDate != null && fixtureDate is String) {
      final parts = fixtureDate.split('T');
      if (parts.length >= 2) {
        date = parts[0];
        time = parts[1].substring(0, 5);
      }
    }
    
    return Match(
      id: json['fixture']['id'] ?? 0,
      date: date,
      time: time,
      status: json['fixture']['status']['short'] ?? 'NS',
      homeTeam: Team.fromJson(json['teams']['home']),
      awayTeam: Team.fromJson(json['teams']['away']),
      score: json['goals']['home'] != null || json['goals']['away'] != null
          ? Score.fromJson(json['goals'])
          : null,
      league: League.fromJson(json['league']),
      venue: json['fixture']['venue']['name'] ?? 'TBD',
    );
  }
}

class MatchDetails extends Match {
  final List<Event> events;
  final List<Lineup> lineups;
  final Statistics statistics;

  MatchDetails({
    required super.id,
    required super.date,
    required super.time,
    required super.status,
    required super.homeTeam,
    required super.awayTeam,
    super.score,
    required super.league,
    required super.venue,
    required this.events,
    required this.lineups,
    required this.statistics,
  });

  factory MatchDetails.fromJson(Map<String, dynamic> json) {
    final fixtureDate = json['fixture']['date'];
    String date = 'TBD';
    String time = 'TBD';
    
    if (fixtureDate != null && fixtureDate is String) {
      final parts = fixtureDate.split('T');
      if (parts.length >= 2) {
        date = parts[0];
        time = parts[1].substring(0, 5);
      }
    }
    
    return MatchDetails(
      id: json['fixture']['id'] ?? 0,
      date: date,
      time: time,
      status: json['fixture']['status']['short'] ?? 'NS',
      homeTeam: Team.fromJson(json['teams']['home']),
      awayTeam: Team.fromJson(json['teams']['away']),
      score: json['goals']['home'] != null || json['goals']['away'] != null
          ? Score.fromJson(json['goals'])
          : null,
      league: League.fromJson(json['league']),
      venue: json['fixture']['venue']['name'] ?? 'TBD',
      events: _parseEvents(json['events']),
      lineups: _parseLineups(json['lineups']),
      statistics: _parseStatistics(json['statistics']),
    );
  }

  static List<Event> _parseEvents(dynamic events) {
    if (events == null) return [];
    if (events is List) {
      return events.map((e) {
        try {
          return Event.fromJson(e);
        } catch (ex) {
          return null;
        }
      }).where((e) => e != null).cast<Event>().toList();
    }
    return [];
  }

  static List<Lineup> _parseLineups(dynamic lineups) {
    if (lineups == null) return [];
    if (lineups is List) {
      return lineups.map((l) {
        try {
          return Lineup.fromJson(l);
        } catch (ex) {
          return null;
        }
      }).where((l) => l != null).cast<Lineup>().toList();
    }
    return [];
  }

  static Statistics _parseStatistics(dynamic statistics) {
    if (statistics == null) return Statistics(home: {}, away: {});
    if (statistics is List && statistics.isNotEmpty) {
      // If statistics is a list, try to convert it to the expected format
      Map<String, dynamic> home = {};
      Map<String, dynamic> away = {};
      
      try {
        if (statistics.length >= 2) {
          home = statistics[0] is Map ? Map<String, dynamic>.from(statistics[0]) : {};
          away = statistics[1] is Map ? Map<String, dynamic>.from(statistics[1]) : {};
        }
      } catch (e) {
        // If parsing fails, return empty statistics
      }
      
      return Statistics(home: home, away: away);
    }
    if (statistics is Map) {
      return Statistics.fromJson(Map<String, dynamic>.from(statistics));
    }
    return Statistics(home: {}, away: {});
  }
}

class Team {
  final int id;
  final String name;
  final String logo;
  final bool winner;

  Team({
    required this.id,
    required this.name,
    required this.logo,
    this.winner = false,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Team',
      logo: json['logo'] ?? '',
      winner: json['winner'] ?? false,
    );
  }
}

class Score {
  final int? home;
  final int? away;

  Score({this.home, this.away});

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      home: json['home'],
      away: json['away'],
    );
  }

  @override
  String toString() {
    return '${home ?? 0} - ${away ?? 0}';
  }
}

class League {
  final int id;
  final String name;
  final String country;
  final String logo;
  final String flag;
  final int season;
  final String round;

  League({
    required this.id,
    required this.name,
    required this.country,
    required this.logo,
    required this.flag,
    required this.season,
    required this.round,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown League',
      country: json['country'] ?? 'Unknown Country',
      logo: json['logo'] ?? '',
      flag: json['flag'] ?? '',
      season: (json['season'] is int) ? json['season'] : 2024,
      round: json['round'] ?? 'Regular Season',
    );
  }
}

class Country {
  final String name;
  final String code;
  final String flag;

  Country({
    required this.name,
    required this.code,
    required this.flag,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'],
      code: json['code'],
      flag: json['flag'],
    );
  }
}

class Event {
  final int time;
  final String type;
  final String detail;
  final Team team;
  final Player? player; // Player involved in the event
  final Player? assist; // Player who assisted (for goals)
  final Player? playerOut; // Player going out (for substitutions)
  final Player? playerIn; // Player coming in (for substitutions)
  final String? comments; // Additional comments
  final String? eventType; // More specific event type (e.g., "Normal Goal", "Penalty")

  Event({
    required this.time,
    required this.type,
    required this.detail,
    required this.team,
    this.player,
    this.assist,
    this.playerOut,
    this.playerIn,
    this.comments,
    this.eventType,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      time: json['time']?['elapsed'] ?? 0,
      type: json['type'] ?? 'Unknown',
      detail: json['detail'] ?? 'No details',
      team: Team.fromJson(json['team'] ?? {}),
      player: json['player'] != null ? Player.fromJson(json['player']) : null,
      assist: json['assist'] != null ? Player.fromJson(json['assist']) : null,
      playerOut: json['playerOut'] != null ? Player.fromJson(json['playerOut']) : null,
      playerIn: json['playerIn'] != null ? Player.fromJson(json['playerIn']) : null,
      comments: json['comments'],
      eventType: json['type'] ?? json['detail'],
    );
  }
}

class Lineup {
  final Team team;
  final List<Player> starting;
  final List<Player> substitutes;
  final List<Player> coach;

  Lineup({
    required this.team,
    required this.starting,
    required this.substitutes,
    required this.coach,
  });

  factory Lineup.fromJson(Map<String, dynamic> json) {
    return Lineup(
      team: Team.fromJson(json['team'] ?? {}),
      starting: _parsePlayerList(json['startXI']),
      substitutes: _parsePlayerList(json['substitutes']),
      coach: _parsePlayerList(json['coach']),
    );
  }

  static List<Player> _parsePlayerList(dynamic playerData) {
    if (playerData == null) return [];
    if (playerData is! List) return [];
    
    return playerData.map((p) {
      try {
        if (p is Map && p['player'] != null) {
          return Player.fromJson(p['player']);
        }
        return null;
      } catch (e) {
        return null;
      }
    }).where((p) => p != null).cast<Player>().toList();
  }
}

class Player {
  final int id;
  final String name;
  final int number;
  final String position;
  final String grid;

  Player({
    required this.id,
    required this.name,
    required this.number,
    required this.position,
    required this.grid,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Player',
      number: json['number'] ?? 0,
      position: json['pos'] ?? 'Unknown',
      grid: json['grid'] ?? '',
    );
  }
}

class Statistics {
  final Map<String, dynamic> home;
  final Map<String, dynamic> away;

  Statistics({required this.home, required this.away});

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      home: json['0'] ?? {},
      away: json['1'] ?? {},
    );
  }
}

class Standing {
  final int rank;
  final Team team;
  final int points;
  final int goalsDiff;
  final int played;
  final int win;
  final int draw;
  final int lose;
  final int goalsFor;
  final int goalsAgainst;

  Standing({
    required this.rank,
    required this.team,
    required this.points,
    required this.goalsDiff,
    required this.played,
    required this.win,
    required this.draw,
    required this.lose,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  factory Standing.fromJson(Map<String, dynamic> json) {
    return Standing(
      rank: json['rank'] ?? 0,
      team: Team.fromJson(json['team'] ?? {}),
      points: json['points'] ?? 0,
      goalsDiff: json['goalsDiff'] ?? 0,
      played: json['all']['played'] ?? 0,
      win: json['all']['win'] ?? 0,
      draw: json['all']['draw'] ?? 0,
      lose: json['all']['lose'] ?? 0,
      goalsFor: json['all']['goals']['for'] ?? 0,
      goalsAgainst: json['all']['goals']['against'] ?? 0,
    );
  }
}
