class Score {
  final int? home;
  final int? away;

  Score({
    this.home,
    this.away,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      home: json['home'] as int?,
      away: json['away'] as int?,
    );
  }
}
