import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_competition.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_competitions';

  // Get all favorite competitions
  static Future<List<FavoriteCompetition>> getFavoriteCompetitions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      return favoritesJson
          .map((json) => FavoriteCompetition.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Add competition to favorites
  static Future<bool> addToFavorites(FavoriteCompetition competition) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteCompetitions();

      // Check if already exists
      if (favorites.any((fav) => fav.id == competition.id)) {
        return true; // Already in favorites
      }

      // Add new favorite
      final newFavorite = competition.copyWith(isFavorite: true);
      favorites.add(newFavorite);

      // Save to preferences
      final favoritesJson =
          favorites.map((fav) => jsonEncode(fav.toJson())).toList();

      return await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      return false;
    }
  }

  // Remove competition from favorites
  static Future<bool> removeFromFavorites(int competitionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteCompetitions();

      // Remove from list
      favorites.removeWhere((fav) => fav.id == competitionId);

      // Save to preferences
      final favoritesJson =
          favorites.map((fav) => jsonEncode(fav.toJson())).toList();

      return await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      return false;
    }
  }

  // Check if competition is favorite
  static Future<bool> isFavorite(int competitionId) async {
    try {
      final favorites = await getFavoriteCompetitions();
      return favorites.any((fav) => fav.id == competitionId);
    } catch (e) {
      return false;
    }
  }

  // Toggle favorite status
  static Future<bool> toggleFavorite(FavoriteCompetition competition) async {
    try {
      final isFav = await isFavorite(competition.id);

      if (isFav) {
        return await removeFromFavorites(competition.id);
      } else {
        return await addToFavorites(competition);
      }
    } catch (e) {
      return false;
    }
  }
}
