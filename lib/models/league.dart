class League {
  final int id;
  final String name;
  final String country;
  final String logo;
  final String flag;

  League({
    required this.id,
    required this.name,
    required this.country,
    required this.logo,
    required this.flag,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'] as int,
      name: json['name'] as String,
      country: json['country'] as String,
      logo: json['logo'] as String,
      flag: json['flag'] as String,
    );
  }
}
