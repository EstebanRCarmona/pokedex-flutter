import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesNotifier extends InheritedWidget {
  final Set<String> favoriteIds;
  final void Function(String id) toggleFavorite;

  const FavoritesNotifier({
    super.key,
    required this.favoriteIds,
    required this.toggleFavorite,
    required super.child,
  });

  bool isFavorite(String id) => favoriteIds.contains(id);

  static FavoritesNotifier of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FavoritesNotifier>()!;

  @override
  bool updateShouldNotify(FavoritesNotifier oldWidget) =>
      favoriteIds != oldWidget.favoriteIds;

  static Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favoriteIds')?.toSet() ?? {};
  }

  static Future<void> saveFavorites(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favoriteIds', ids.toList());
  }
}
