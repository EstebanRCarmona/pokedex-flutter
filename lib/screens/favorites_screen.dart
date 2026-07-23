import 'package:flutter/material.dart';
import 'package:pokedex_flutter/models/pokemon.dart';
import 'package:pokedex_flutter/services/pokemon_service.dart';
import 'package:pokedex_flutter/widgets/favorites_notifier.dart';
import 'package:pokedex_flutter/widgets/pockemon_card.dart';
import 'package:pokedex_flutter/widgets/pokemon_card_skeleton.dart';
import 'package:pokedex_flutter/widgets/theme_notifier.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _service = PokemonService();

  List<PokemonDetail> _favorites = [];
  bool _loading = false;
  Set<String> _loadedIds = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentIds = FavoritesNotifier.of(context).favoriteIds;
    if (currentIds != _loadedIds) {
      _loadedIds = currentIds;
      _loadFavorites(currentIds);
    }
  }

  Future<void> _loadFavorites(Set<String> ids) async {
    if (ids.isEmpty) {
      setState(() => _favorites = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final results = await Future.wait(ids.map(_service.fetchPokemonDetail));
      setState(() {
        _favorites = results;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favoritos',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => ThemeNotifier.of(context).toggle(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final favNotifier = FavoritesNotifier.of(context);

    if (_loading) {
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
        ),
        itemCount: favNotifier.favoriteIds.length,
        itemBuilder: (_, _) => const PokemonCardSkeleton(),
      );
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.catching_pokemon,
                size: 80,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)),
            const SizedBox(height: 16),
            Text(
              'Sin favoritos aún',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Toca ❤️ en cualquier pokémon para guardarlo',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                  ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
      ),
      itemCount: _favorites.length,
      itemBuilder: (_, i) => PokemonCard(pokemon: _favorites[i]),
    );
  }
}
