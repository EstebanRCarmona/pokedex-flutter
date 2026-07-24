import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokedex_flutter/theme/app_theme.dart';
import 'package:pokedex_flutter/router/app_router.dart';
import 'package:pokedex_flutter/widgets/theme_notifier.dart';
import 'package:pokedex_flutter/widgets/favorites_notifier.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? false;
  final favoriteIds = await FavoritesNotifier.loadFavorites();
  FlutterNativeSplash.remove();
  runApp(MyApp(isDark: isDark, favoriteIds: favoriteIds));
}

class MyApp extends StatefulWidget {
  final bool isDark;
  final Set<String> favoriteIds;
  const MyApp({super.key, required this.isDark, required this.favoriteIds});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDark;
  late Set<String> _favoriteIds;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
    _favoriteIds = widget.favoriteIds;
  }

  void _toggleTheme() async {
    setState(() => _isDark = !_isDark);
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', _isDark);
  }

  void _toggleFavorite(String id) {
    HapticFeedback.mediumImpact();
    setState(() {
      final updated = Set<String>.from(_favoriteIds);
      if (updated.contains(id)) {
        updated.remove(id);
      } else {
        updated.add(id);
      }
      _favoriteIds = updated;
    });
    FavoritesNotifier.saveFavorites(_favoriteIds);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeNotifier(
      isDark: _isDark,
      toggle: _toggleTheme,
      child: FavoritesNotifier(
        favoriteIds: _favoriteIds,
        toggleFavorite: _toggleFavorite,
        child: MaterialApp.router(
          title: 'Pokédex',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
