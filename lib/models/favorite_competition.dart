class FavoriteCompetition {
  final int id;
  final String name;
  final String logo;
  final String country;
  final bool isFavorite;

  FavoriteCompetition({
    required this.id,
    required this.name,
    required this.logo,
    required this.country,
    this.isFavorite = false,
  });

  FavoriteCompetition copyWith({
    int? id,
    String? name,
    String? logo,
    String? country,
    bool? isFavorite,
  }) {
    return FavoriteCompetition(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      country: country ?? this.country,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'country': country,
      'isFavorite': isFavorite,
    };
  }

  factory FavoriteCompetition.fromJson(Map<String, dynamic> json) {
    return FavoriteCompetition(
      id: json['id'] as int,
      name: json['name'] as String,
      logo: json['logo'] as String,
      country: json['country'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
