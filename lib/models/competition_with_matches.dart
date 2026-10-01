import 'match.dart';

class CompetitionWithMatches {
  final int id;
  final String name;
  final String country;
  final String logo;
  final String flag;
  final List<Match> matches;

  CompetitionWithMatches({
    required this.id,
    required this.name,
    required this.country,
    required this.logo,
    required this.flag,
    required this.matches,
  });
}
