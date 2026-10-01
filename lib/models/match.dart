import 'team.dart';
import 'league.dart';
import 'score.dart';

class Match {
  final int id;
  final String date;
  final String time;
  final String status;
  final String venue;
  final Team homeTeam;
  final Team awayTeam;
  final League league;
  final Score? score;

  Match({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
    required this.venue,
    required this.homeTeam,
    required this.awayTeam,
    required this.league,
    this.score,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['fixture']['id'] as int,
      date: json['fixture']['date'] as String,
      time: json['fixture']['date'] as String, // You might want to parse this differently
      status: json['fixture']['status']['short'] as String,
      venue: json['fixture']['venue']['name'] as String? ?? 'TBD',
      homeTeam: Team.fromJson(json['teams']['home']),
      awayTeam: Team.fromJson(json['teams']['away']),
      league: League.fromJson(json['league']),
      score: json['goals'] != null ? Score.fromJson(json['goals']) : null,
    );
  }
}
