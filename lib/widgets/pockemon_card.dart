import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_flutter/models/pokemon.dart';
import 'package:pokedex_flutter/widgets/type_icon.dart';
import 'package:pokedex_flutter/widgets/favorites_notifier.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typeColor = TypeIcon.colorFor(pokemon.type);

    return Card(
      margin: const EdgeInsets.all(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () =>
            context.pushNamed('details', pathParameters: {'id': pokemon.id}),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        typeColor.withValues(alpha: isDark ? 0.3 : 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${pokemon.id.padLeft(3, '0')}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _FavoriteButton(pokemonId: pokemon.id),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Hero(
                      tag: 'pokemon-${pokemon.id}',
                      child: Image.network(
                        pokemon.imagenUrl,
                        height: 80,
                        width: 80,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : SizedBox(
                                height: 80,
                                width: 80,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: typeColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pokemon.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pokemon.types
                          .where((t) => t.isNotEmpty)
                          .map((t) {
                                final color = TypeIcon.colorFor(t);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TypeIcon(type: t, size: 18),
                                      const SizedBox(height: 3),
                                      Text(
                                        t.toUpperCase(),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: color,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9,
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final String pokemonId;

  const _FavoriteButton({required this.pokemonId});

  @override
  Widget build(BuildContext context) {
    final favNotifier = FavoritesNotifier.of(context);
    final isFav = favNotifier.isFavorite(pokemonId);

    return GestureDetector(
      onTap: () => favNotifier.toggleFavorite(pokemonId),
      child: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav
            ? Colors.redAccent
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
        size: 20,
      ),
    );
  }
}
